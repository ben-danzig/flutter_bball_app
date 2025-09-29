import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/models/drill_template.dart';
import 'package:uuid/uuid.dart';

class DrillLibraryService {
  final List<DrillTemplate> _templates;
  final _uuid = const Uuid();

  // Predefined categories
  static const List<String> validCategories = [
    'Ball Handling',
    'Shooting',
    'Finishing',
    'Defense',
    'Passing',
    'Conditioning',
    'Footwork',
    'Rebounding',
    'Game Situations',
  ];

  // Predefined difficulty levels
  static const List<String> validDifficulties = [
    'beginner',
    'intermediate',
    'advanced',
  ];

  // Valid drill types
  static const List<String> validDrillTypes = [
    'TIMED',
    'REP_BASED',
    'MAKE_TARGET_TIMED',
    'READ_AND_REACT',
  ];

  DrillLibraryService({List<DrillTemplate>? templates}) 
      : _templates = templates ?? _loadDefaultTemplates();

  /// Loads default drill templates (in production, this would load from assets or API)
  static List<DrillTemplate> _loadDefaultTemplates() {
    // This is a placeholder. In production, templates would be loaded from assets or API
    return [
      // Ball Handling Templates
      DrillTemplate(
        id: 'default_basic_dribbling',
        name: 'Basic Dribbling',
        description: 'Practice fundamental dribbling moves',
        type: 'TIMED',
        category: 'Ball Handling',
        difficulty: 'beginner',
        tags: ['dribbling', 'fundamentals'],
        defaultConfig: {'duration': 60, 'sets': 3},
        configOptions: {
          'duration': {'min': 30, 'max': 300, 'step': 15},
          'sets': {'min': 1, 'max': 5, 'step': 1},
        },
      ),
      DrillTemplate(
        id: 'default_crossover_series',
        name: 'Crossover Series',
        description: 'Master crossover dribbles at different speeds',
        type: 'TIMED',
        category: 'Ball Handling',
        difficulty: 'intermediate',
        tags: ['dribbling', 'crossover'],
        defaultConfig: {'duration': 45, 'sets': 3},
        configOptions: {
          'duration': {'min': 30, 'max': 120, 'step': 15},
          'sets': {'min': 1, 'max': 5, 'step': 1},
        },
      ),
      
      // Shooting Templates
      DrillTemplate(
        id: 'default_free_throws',
        name: 'Free Throw Practice',
        description: 'Build consistency at the free throw line',
        type: 'REP_BASED',
        category: 'Shooting',
        difficulty: 'beginner',
        tags: ['shooting', 'free throws'],
        defaultConfig: {'targetMakes': 10, 'sets': 5},
        configOptions: {
          'targetMakes': {'min': 5, 'max': 50, 'step': 5},
          'sets': {'min': 1, 'max': 10, 'step': 1},
        },
      ),
      DrillTemplate(
        id: 'default_spot_shooting',
        name: 'Spot Shooting',
        description: 'Shoot from designated spots around the arc',
        type: 'MAKE_TARGET_TIMED',
        category: 'Shooting',
        difficulty: 'intermediate',
        tags: ['shooting', '3-point'],
        defaultConfig: {'targetMakes': 15},
        configOptions: {
          'targetMakes': {'min': 5, 'max': 50, 'step': 5},
        },
      ),
      
      // Finishing Templates
      DrillTemplate(
        id: 'default_layup_lines',
        name: 'Layup Lines',
        description: 'Basic layup practice from both sides',
        type: 'REP_BASED',
        category: 'Finishing',
        difficulty: 'beginner',
        tags: ['finishing', 'layups'],
        defaultConfig: {'targetMakes': 20, 'sets': 1},
        configOptions: {
          'targetMakes': {'min': 10, 'max': 50, 'step': 5},
          'sets': {'min': 1, 'max': 3, 'step': 1},
        },
      ),
      DrillTemplate(
        id: 'default_finishing_gauntlet',
        name: 'Finishing Gauntlet',
        description: 'Make layups from various angles as fast as possible',
        type: 'MAKE_TARGET_TIMED',
        category: 'Finishing',
        difficulty: 'advanced',
        tags: ['finishing', 'layups', 'speed'],
        defaultConfig: {'targetMakes': 25},
        configOptions: {
          'targetMakes': {'min': 10, 'max': 50, 'step': 5},
        },
      ),
      
      // Game Situations Templates
      DrillTemplate(
        id: 'default_wing_decisions',
        name: 'Wing Decision Making',
        description: 'React to cues: shoot, drive left, or drive right',
        type: 'READ_AND_REACT',
        category: 'Game Situations',
        difficulty: 'advanced',
        tags: ['decision making', 'reaction', 'game speed'],
        defaultConfig: {'reps': 10, 'intervalSeconds': 20},
        configOptions: {
          'reps': {'min': 5, 'max': 20, 'step': 1},
          'intervalSeconds': {'min': 10, 'max': 30, 'step': 5},
        },
      ),
    ];
  }

  /// Gets all available drill templates
  Future<List<DrillTemplate>> getAllTemplates() async {
    return List.unmodifiable(_templates);
  }

  /// Gets templates by category
  Future<List<DrillTemplate>> getTemplatesByCategory(String category) async {
    return _templates.where((t) => t.category == category).toList();
  }

  /// Gets templates by drill type
  Future<List<DrillTemplate>> getTemplatesByType(String type) async {
    return _templates.where((t) => t.type == type).toList();
  }

  /// Searches templates by name, description, or tags
  Future<List<DrillTemplate>> searchTemplates(String query) async {
    final lowerQuery = query.toLowerCase();
    return _templates.where((t) =>
        t.name.toLowerCase().contains(lowerQuery) ||
        t.description.toLowerCase().contains(lowerQuery) ||
        t.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))
    ).toList();
  }

  /// Filters templates by multiple criteria
  Future<List<DrillTemplate>> filterTemplates({
    String? category,
    String? type,
    String? difficulty,
    List<String>? tags,
  }) async {
    var filtered = _templates;

    if (category != null) {
      filtered = filtered.where((t) => t.category == category).toList();
    }
    
    if (type != null) {
      filtered = filtered.where((t) => t.type == type).toList();
    }
    
    if (difficulty != null) {
      filtered = filtered.where((t) => t.difficulty == difficulty).toList();
    }
    
    if (tags != null && tags.isNotEmpty) {
      filtered = filtered.where((t) =>
          tags.any((tag) => t.tags.contains(tag))
      ).toList();
    }

    return filtered;
  }

  /// Gets a specific template by ID
  Future<DrillTemplate?> getTemplateById(String id) async {
    try {
      return _templates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Creates a drill instance from a template
  Future<Drill> createDrillFromTemplate(
    DrillTemplate template, {
    Map<String, dynamic>? customConfig,
  }) async {
    final config = customConfig ?? template.defaultConfig;
    
    // Validate config if custom config provided
    if (customConfig != null) {
      _validateConfigAgainstOptions(template, customConfig);
    }
    
    return Drill(
      drillId: _uuid.v4(),
      name: template.name,
      description: template.description,
      type: template.type,
      config: config,
    );
  }

  /// Validates custom config against template options
  void _validateConfigAgainstOptions(
    DrillTemplate template,
    Map<String, dynamic> config,
  ) {
    for (final entry in config.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (!template.configOptions.containsKey(key)) {
        throw Exception('Invalid config parameter: $key');
      }
      
      final options = template.configOptions[key]!;
      
      if (options.containsKey('min') && value < options['min']) {
        throw Exception('$key value $value is below minimum ${options['min']}');
      }
      
      if (options.containsKey('max') && value > options['max']) {
        throw Exception('$key value $value exceeds maximum ${options['max']}');
      }
    }
  }

  /// Gets all unique categories from templates
  Future<List<String>> getCategories() async {
    final categories = _templates.map((t) => t.category).toSet().toList();
    categories.sort();
    return categories;
  }

  /// Gets all drill types
  Future<List<String>> getDrillTypes() async {
    return List.unmodifiable(validDrillTypes);
  }

  /// Gets all difficulty levels
  Future<List<String>> getDifficulties() async {
    return List.unmodifiable(validDifficulties);
  }

  /// Validates drill configuration for a specific type
  Future<bool> validateDrillConfig(String type, Map<String, dynamic> config) async {
    switch (type) {
      case 'TIMED':
        return config.containsKey('duration') && 
               config['duration'] is int &&
               config.containsKey('sets') &&
               config['sets'] is int;
               
      case 'REP_BASED':
        return config.containsKey('targetMakes') &&
               config['targetMakes'] is int &&
               config.containsKey('sets') &&
               config['sets'] is int;
               
      case 'MAKE_TARGET_TIMED':
        return config.containsKey('targetMakes') &&
               config['targetMakes'] is int;
               
      case 'READ_AND_REACT':
        return config.containsKey('reps') &&
               config['reps'] is int &&
               config.containsKey('intervalSeconds') &&
               config['intervalSeconds'] is int;
               
      default:
        return false;
    }
  }

  /// Gets default configuration for a drill type
  Future<Map<String, dynamic>> getDefaultConfig(String type) async {
    switch (type) {
      case 'TIMED':
        return {'duration': 60, 'sets': 1};
        
      case 'REP_BASED':
        return {'targetMakes': 10, 'sets': 1};
        
      case 'MAKE_TARGET_TIMED':
        return {'targetMakes': 10};
        
      case 'READ_AND_REACT':
        return {'reps': 10, 'intervalSeconds': 20};
        
      default:
        return {};
    }
  }
}