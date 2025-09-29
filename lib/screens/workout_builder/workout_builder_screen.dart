import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bball_app/providers/workout_builder_provider.dart';
import 'package:flutter_bball_app/screens/workout_builder/drill_library_screen.dart';
import 'package:flutter_bball_app/models/drill.dart';

class WorkoutBuilderScreen extends StatefulWidget {
  const WorkoutBuilderScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutBuilderScreen> createState() => _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends State<WorkoutBuilderScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _objectiveController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _objectiveController.dispose();
    super.dispose();
  }

  void _addDrill() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DrillLibraryScreen(
          onDrillSelected: (Drill drill) {
            final provider = Provider.of<WorkoutBuilderProvider>(context, listen: false);
            provider.addDrill(drill);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _saveWorkout() async {
    final provider = Provider.of<WorkoutBuilderProvider>(context, listen: false);
    
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a workout name')),
      );
      return;
    }

    if (_objectiveController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a workout objective')),
      );
      return;
    }

    if (provider.drills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one drill')),
      );
      return;
    }

    try {
      // Update provider with form data
      provider.updateName(_nameController.text.trim());
      provider.updateObjective(_objectiveController.text.trim());
      
      // Create the workout using the provider
      final created = await provider.createWorkout();
      
      if (created != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout saved successfully!')),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving workout. Please check all fields.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving workout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Build Workout',
          style: textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<WorkoutBuilderProvider>(
            builder: (context, provider, child) {
              return TextButton(
                onPressed: provider.drills.isNotEmpty ? _saveWorkout : null,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: provider.drills.isNotEmpty 
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF6B7280),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWorkoutDetailsSection(textTheme),
              const SizedBox(height: 24),
              _buildDrillsSection(textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutDetailsSection(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout Details',
          style: textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nameController,
          label: 'Workout Name',
          hint: 'Enter workout name',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _objectiveController,
          label: 'Objective',
          hint: 'What is the goal of this workout?',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF6B7280)),
            filled: true,
            fillColor: const Color(0xFF1F2937),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4B5563)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4B5563)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrillsSection(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Drills',
              style: textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Consumer<WorkoutBuilderProvider>(
              builder: (context, provider, child) {
                if (provider.drills.isNotEmpty) {
                  return Text(
                    '${provider.estimatedDuration} min',
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<WorkoutBuilderProvider>(
          builder: (context, provider, child) {
            if (provider.drills.isEmpty) {
              return _buildEmptyDrillsState();
            }
            return _buildDrillsList(provider);
          },
        ),
        const SizedBox(height: 16),
        _buildAddDrillButton(),
      ],
    );
  }

  Widget _buildEmptyDrillsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4B5563)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center,
            size: 48,
            color: const Color(0xFF6B7280),
          ),
          const SizedBox(height: 16),
          Text(
            'No drills added yet',
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add drills to build your workout',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrillsList(WorkoutBuilderProvider provider) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.drills.length,
      onReorder: (oldIndex, newIndex) {
        provider.reorderDrills(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final drill = provider.drills[index];
        return _buildDrillCard(drill, index, provider);
      },
    );
  }

  Widget _buildDrillCard(Drill drill, int index, WorkoutBuilderProvider provider) {
    return Container(
      key: ValueKey(drill.drillId),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4B5563)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drill.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  drill.type.toString().split('.').last.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: const Color(0xFF6B7280),
            onPressed: () => provider.removeDrill(index),
          ),
          const Icon(
            Icons.drag_handle,
            color: Color(0xFF6B7280),
          ),
        ],
      ),
    );
  }

  Widget _buildAddDrillButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _addDrill,
        icon: const Icon(Icons.add),
        label: const Text('Add Drill'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
