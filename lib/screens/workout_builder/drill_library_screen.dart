import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bball_app/services/drill_library_service.dart';
import 'package:flutter_bball_app/models/drill_template.dart';
import 'package:flutter_bball_app/models/drill.dart';

class DrillLibraryScreen extends StatefulWidget {
  final Function(Drill) onDrillSelected;

  const DrillLibraryScreen({
    Key? key,
    required this.onDrillSelected,
  }) : super(key: key);

  @override
  State<DrillLibraryScreen> createState() => _DrillLibraryScreenState();
}

class _DrillLibraryScreenState extends State<DrillLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedDifficulty;
  String? _selectedType;
  bool _showFilters = false;
  List<DrillTemplate> _templates = [];
  List<DrillTemplate> _filteredTemplates = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = Provider.of<DrillLibraryService>(context, listen: false);
      final templates = await service.getAllTemplates();
      setState(() {
        _templates = templates;
        _filteredTemplates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load drills';
        _isLoading = false;
      });
    }
  }

  Future<void> _applyFilters() async {
    final service = Provider.of<DrillLibraryService>(context, listen: false);
    
    try {
      List<DrillTemplate> filtered;
      
      // If search text exists, use search
      if (_searchController.text.isNotEmpty) {
        filtered = await service.searchTemplates(_searchController.text);
      } else {
        // Otherwise use filters
        filtered = await service.filterTemplates(
          category: _selectedCategory,
          difficulty: _selectedDifficulty,
          type: _selectedType,
        );
      }
      
      setState(() {
        _filteredTemplates = filtered;
      });
    } catch (e) {
      // Handle error
      print('Error applying filters: $e');
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedDifficulty = null;
      _selectedType = null;
      _searchController.clear();
      _filteredTemplates = _templates;
    });
  }

  void _showDrillDetails(DrillTemplate template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DrillDetailsSheet(
        template: template,
        onSelect: (config) async {
          final service = Provider.of<DrillLibraryService>(context, listen: false);
          final drill = await service.createDrillFromTemplate(
            template,
            customConfig: config,
          );
          widget.onDrillSelected(drill);
          Navigator.of(context).pop(); // Close details sheet
          Navigator.of(context).pop(); // Close library screen
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drill Library'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search drills...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onSubmitted: (_) => _applyFilters(),
              textInputAction: TextInputAction.search,
            ),
          ),
          
          // Filters
          if (_showFilters) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category filters
                  const Text('Category:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  FutureBuilder<List<String>>(
                    future: Provider.of<DrillLibraryService>(context, listen: false).getCategories(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      return Wrap(
                        spacing: 8,
                        children: snapshot.data!.map((category) {
                          return FilterChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? category : null;
                              });
                              _applyFilters();
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Difficulty filters
                  const Text('Difficulty:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  FutureBuilder<List<String>>(
                    future: Provider.of<DrillLibraryService>(context, listen: false).getDifficulties(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      return Wrap(
                        spacing: 8,
                        children: snapshot.data!.map((difficulty) {
                          return FilterChip(
                            label: Text(difficulty),
                            selected: _selectedDifficulty == difficulty,
                            onSelected: (selected) {
                              setState(() {
                                _selectedDifficulty = selected ? difficulty : null;
                              });
                              _applyFilters();
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Clear filters button
                  Center(
                    child: TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear Filters'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
          
          // Drill Grid
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTemplates,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_filteredTemplates.isEmpty) {
      return const Center(
        child: Text('No drills found'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredTemplates.length,
      itemBuilder: (context, index) {
        final template = _filteredTemplates[index];
        return DrillCard(
          template: template,
          onTap: () => _showDrillDetails(template),
        );
      },
    );
  }
}

class DrillCard extends StatelessWidget {
  final DrillTemplate template;
  final VoidCallback onTap;

  const DrillCard({
    Key? key,
    required this.template,
    required this.onTap,
  }) : super(key: key);

  Color _getDifficultyColor() {
    switch (template.difficulty) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  template.type,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Title
              Text(
                template.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              
              // Description
              Text(
                template.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              
              // Bottom row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Difficulty indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  
                  // Category
                  Text(
                    template.category,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrillDetailsSheet extends StatefulWidget {
  final DrillTemplate template;
  final Function(Map<String, dynamic>?) onSelect;

  const DrillDetailsSheet({
    Key? key,
    required this.template,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<DrillDetailsSheet> createState() => _DrillDetailsSheetState();
}

class _DrillDetailsSheetState extends State<DrillDetailsSheet> {
  late Map<String, dynamic> _currentConfig;

  @override
  void initState() {
    super.initState();
    _currentConfig = Map.from(widget.template.defaultConfig);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              const Text(
                'Drill Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.template.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.template.description),
                      const SizedBox(height: 16),
                      
                      // Metadata
                      Text('Type: ${widget.template.type}'),
                      Text('Category: ${widget.template.category}'),
                      Text('Difficulty: ${widget.template.difficulty}'),
                      Text('Tags: ${widget.template.tags.join(', ')}'),
                      const SizedBox(height: 24),
                      
                      // Configuration
                      const Text(
                        'Configuration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Dynamic config fields
                      ...widget.template.configOptions.entries.map((entry) {
                        final key = entry.key;
                        final options = entry.value;
                        final currentValue = _currentConfig[key] ?? widget.template.defaultConfig[key];
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatConfigKey(key),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            if (options['min'] != null && options['max'] != null) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: Slider(
                                      value: currentValue.toDouble(),
                                      min: options['min'].toDouble(),
                                      max: options['max'].toDouble(),
                                      divisions: ((options['max'] - options['min']) / (options['step'] ?? 1)).round(),
                                      label: currentValue.toString(),
                                      onChanged: (value) {
                                        setState(() {
                                          _currentConfig[key] = value.round();
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: Text(
                                      currentValue.toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => widget.onSelect(_currentConfig),
                      child: const Text('Select Drill'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatConfigKey(String key) {
    // Convert camelCase to Title Case
    return key.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    ).split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ').trim();
  }
}