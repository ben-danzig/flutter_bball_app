import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bball_app/models/custom_workout_blueprint.dart';
import 'package:flutter_bball_app/models/drill.dart';
import 'package:flutter_bball_app/repositories/custom_workout_repository.dart';
import 'package:uuid/uuid.dart';

class WorkoutBuilderProvider extends ChangeNotifier {
  final CustomWorkoutRepository repository;
  final _uuid = const Uuid();
  
  // Workout metadata
  String _workoutId = '';
  String _name = '';
  String _objective = '';
  String? _category;
  String _difficulty = 'beginner';
  List<String> _tags = [];
  bool _isPublic = false;
  String _userId = '';
  
  // Drills
  List<Drill> _drills = [];
  
  // UI State
  int _currentStep = 0;
  bool _isLoading = false;
  
  // Validation errors
  String? _nameError;
  String? _objectiveError;
  String? _categoryError;
  String? _tagsError;
  String? _drillsError;
  
  // Auto-save timer
  Timer? _autoSaveTimer;
  
  WorkoutBuilderProvider({required this.repository}) {
    _loadDraftOnInit();
  }
  
  // Getters
  String get workoutId => _workoutId;
  String get name => _name;
  String get objective => _objective;
  String? get category => _category;
  String get difficulty => _difficulty;
  List<String> get tags => List.unmodifiable(_tags);
  bool get isPublic => _isPublic;
  List<Drill> get drills => List.unmodifiable(_drills);
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  
  String? get nameError => _nameError;
  String? get objectiveError => _objectiveError;
  String? get categoryError => _categoryError;
  String? get tagsError => _tagsError;
  String? get drillsError => _drillsError;
  
  int get estimatedDuration {
    int totalSeconds = 0;
    for (final drill in _drills) {
      switch (drill.type) {
        case 'TIMED':
          final duration = drill.config['duration'] ?? 0;
          final sets = drill.config['sets'] ?? 1;
          totalSeconds += (duration * sets);
          break;
        case 'REP_BASED':
          // Estimate 3 seconds per rep
          final targetMakes = drill.config['targetMakes'] ?? 0;
          final sets = drill.config['sets'] ?? 1;
          totalSeconds += (targetMakes * 3 * sets);
          break;
        case 'MAKE_TARGET_TIMED':
          // Estimate based on target makes
          final targetMakes = drill.config['targetMakes'] ?? 0;
          totalSeconds += (targetMakes * 10); // 10 seconds per make average
          break;
        case 'READ_AND_REACT':
          final reps = drill.config['reps'] ?? 0;
          final interval = drill.config['intervalSeconds'] ?? 0;
          totalSeconds += (reps * interval);
          break;
      }
    }
    return (totalSeconds / 60).ceil(); // Convert to minutes
  }
  
  bool get isValid {
    return validationErrors.isEmpty;
  }
  
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (_name.isEmpty) {
      errors.add('Name is required');
    } else if (_name.length < 3) {
      errors.add('Name must be at least 3 characters');
    } else if (_name.length > 50) {
      errors.add('Name must not exceed 50 characters');
    }
    
    if (_objective.isEmpty) {
      errors.add('Objective is required');
    }
    
    if (_category == null || _category!.isEmpty) {
      errors.add('Category is required');
    }
    
    if (_drills.isEmpty) {
      errors.add('At least one drill is required');
    } else if (_drills.length > 20) {
      errors.add('Maximum 20 drills allowed');
    }
    
    if (estimatedDuration < 5) {
      errors.add('Workout must be at least 5 minutes');
    } else if (estimatedDuration > 120) {
      errors.add('Workout must not exceed 120 minutes');
    }
    
    if (_tags.length > 10) {
      errors.add('Maximum 10 tags allowed');
    }
    
    return errors;
  }
  
  bool get canProceedToNextStep {
    switch (_currentStep) {
      case 0: // Metadata step
        return _name.isNotEmpty && 
               _name.length >= 3 && 
               _name.length <= 50 &&
               _objective.isNotEmpty && 
               _category != null;
      case 1: // Drills step
        return _drills.isNotEmpty && 
               _drills.length <= 20 &&
               estimatedDuration >= 5 &&
               estimatedDuration <= 120;
      case 2: // Review step
        return isValid;
      default:
        return false;
    }
  }
  
  // Initialization
  Future<void> _loadDraftOnInit() async {
    await loadDraft();
  }
  
  Future<void> loadDraft() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final draft = await repository.loadDraft();
      if (draft != null) {
        _loadFromBlueprint(draft);
      }
    } catch (e) {
      print('Error loading draft: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void _loadFromBlueprint(CustomWorkoutBlueprint blueprint) {
    _workoutId = blueprint.id;
    _name = blueprint.name;
    _objective = blueprint.objective;
    _category = blueprint.category;
    _difficulty = blueprint.difficulty;
    _tags = List.from(blueprint.tags);
    _isPublic = blueprint.isPublic;
    _drills = List.from(blueprint.drills);
    _userId = blueprint.authorId;
  }
  
  // Metadata updates
  void updateName(String value) {
    _name = value;
    _validateName();
    _scheduleAutoSave();
    notifyListeners();
  }
  
  void updateObjective(String value) {
    _objective = value;
    _objectiveError = value.isEmpty ? 'Objective is required' : null;
    _scheduleAutoSave();
    notifyListeners();
  }
  
  void updateCategory(String value) {
    _category = value;
    _categoryError = null;
    _scheduleAutoSave();
    notifyListeners();
  }
  
  void updateDifficulty(String value) {
    _difficulty = value;
    _scheduleAutoSave();
    notifyListeners();
  }
  
  void addTag(String tag) {
    if (!_tags.contains(tag) && _tags.length < 10) {
      _tags.add(tag);
      _tagsError = null;
      _scheduleAutoSave();
      notifyListeners();
    } else if (_tags.length >= 10) {
      _tagsError = 'Maximum 10 tags allowed';
      notifyListeners();
    }
  }
  
  void removeTag(String tag) {
    _tags.remove(tag);
    _tagsError = null;
    _scheduleAutoSave();
    notifyListeners();
  }
  
  void togglePublic() {
    _isPublic = !_isPublic;
    _scheduleAutoSave();
    notifyListeners();
  }
  
  void setUserId(String userId) {
    _userId = userId;
  }
  
  // Drill management
  void addDrill(Drill drill) {
    if (_drills.length < 20) {
      _drills.add(drill);
      _drillsError = null;
      _scheduleAutoSave();
      notifyListeners();
    } else {
      _drillsError = 'Maximum 20 drills allowed';
      notifyListeners();
    }
  }
  
  void removeDrill(int index) {
    if (index >= 0 && index < _drills.length) {
      _drills.removeAt(index);
      _drillsError = null;
      _scheduleAutoSave();
      notifyListeners();
    }
  }
  
  void reorderDrills(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final drill = _drills.removeAt(oldIndex);
    _drills.insert(newIndex, drill);
    _scheduleAutoSave();
    notifyListeners();
  }
  
  // Navigation
  void nextStep() {
    if (_currentStep < 2 && canProceedToNextStep) {
      _currentStep++;
      notifyListeners();
    }
  }
  
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }
  
  // Validation
  void _validateName() {
    if (_name.isEmpty) {
      _nameError = 'Name is required';
    } else if (_name.length < 3) {
      _nameError = 'Name must be at least 3 characters';
    } else if (_name.length > 50) {
      _nameError = 'Name must not exceed 50 characters';
    } else {
      _nameError = null;
    }
  }
  
  // Draft management
  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 500), () {
      _saveDraft();
    });
  }
  
  Future<void> _saveDraft() async {
    if (_name.isEmpty && _objective.isEmpty && _drills.isEmpty) {
      return; // Don't save empty drafts
    }
    
    try {
      final draft = toBlueprint();
      await repository.saveDraft(draft);
    } catch (e) {
      print('Error saving draft: $e');
    }
  }
  
  Future<void> clearDraft() async {
    _workoutId = '';
    _name = '';
    _objective = '';
    _category = null;
    _difficulty = 'beginner';
    _tags.clear();
    _isPublic = false;
    _drills.clear();
    _currentStep = 0;
    
    _nameError = null;
    _objectiveError = null;
    _categoryError = null;
    _tagsError = null;
    _drillsError = null;
    
    try {
      await repository.clearDraft();
    } catch (e) {
      print('Error clearing draft: $e');
    }
    
    notifyListeners();
  }
  
  // Workout creation
  Future<CustomWorkoutBlueprint?> createWorkout() async {
    if (!isValid) {
      return null;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final blueprint = toBlueprint();
      final created = await repository.createWorkout(blueprint);
      await repository.clearDraft();
      return created;
    } catch (e) {
      print('Error creating workout: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Convert to blueprint
  CustomWorkoutBlueprint toBlueprint() {
    return CustomWorkoutBlueprint(
      id: _workoutId.isEmpty ? _uuid.v4() : _workoutId,
      name: _name,
      objective: _objective,
      estimatedDuration: estimatedDuration,
      drills: _drills,
      authorId: _userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      category: _category ?? 'Mixed Skills',
      difficulty: _difficulty,
      tags: _tags,
      isPublic: _isPublic,
      likes: 0,
      version: 1,
    );
  }
  
  // Load existing workout for editing
  void loadFromExisting(CustomWorkoutBlueprint workout) {
    _loadFromBlueprint(workout);
    notifyListeners();
  }
  
  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}