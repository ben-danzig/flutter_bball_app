import '../models/drill.dart';

/// Drill type constants for consistent type checking across the app
class DrillTypes {
  static const String timed = 'TIMED';
  static const String repBased = 'REP_BASED'; 
  static const String makeTargetTimed = 'MAKE_TARGET_TIMED';
  static const String readAndReact = 'READ_AND_REACT';
  
  /// All available drill types
  static const List<String> all = [
    timed,
    repBased,
    makeTargetTimed,
    readAndReact,
  ];
}

/// Enum for type-safe drill type handling
enum DrillType {
  timed,
  repBased,
  makeTargetTimed,
  readAndReact,
}

/// Utilities for working with drill types
class DrillTypeUtils {
  /// Convert string drill type to DrillType enum
  static DrillType? fromString(String? type) {
    if (type == null) return null;
    
    switch (type.toUpperCase()) {
      case DrillTypes.timed:
        return DrillType.timed;
      case DrillTypes.repBased:
        return DrillType.repBased;
      case DrillTypes.makeTargetTimed:
        return DrillType.makeTargetTimed;
      case DrillTypes.readAndReact:
        return DrillType.readAndReact;
      default:
        return null;
    }
  }
  
  /// Convert DrillType enum to string
  static String typeToString(DrillType type) {
    switch (type) {
      case DrillType.timed:
        return DrillTypes.timed;
      case DrillType.repBased:
        return DrillTypes.repBased;
      case DrillType.makeTargetTimed:
        return DrillTypes.makeTargetTimed;
      case DrillType.readAndReact:
        return DrillTypes.readAndReact;
    }
  }
  
  /// Get DrillType from Drill model
  static DrillType? fromDrill(Drill? drill) {
    return fromString(drill?.type);
  }
  
  /// Check if drill type requires a primary action button
  static bool hasPrimaryAction(DrillType? type) {
    if (type == null) return false;
    
    switch (type) {
      case DrillType.makeTargetTimed:
      case DrillType.repBased:
        return true;
      case DrillType.timed:
      case DrillType.readAndReact:
        return false;
    }
  }
  
  /// Get the primary action button text for a drill type
  static String? getPrimaryActionText(DrillType type) {
    switch (type) {
      case DrillType.makeTargetTimed:
        return 'FINISH DRILL';
      case DrillType.repBased:
        return 'LOG SET';
      case DrillType.timed:
      case DrillType.readAndReact:
        return null;
    }
  }
  
  /// Get the primary action button color for a drill type
  static int? getPrimaryActionColor(DrillType type) {
    switch (type) {
      case DrillType.makeTargetTimed:
        return 0xFF10B981; // Green
      case DrillType.repBased:
        return 0xFF3B82F6; // Blue
      case DrillType.timed:
      case DrillType.readAndReact:
        return null;
    }
  }
  
  /// Check if drill type needs completion state tracking
  static bool needsCompletionState(DrillType type) {
    switch (type) {
      case DrillType.makeTargetTimed:
        return true; // Needs to track if target makes reached
      case DrillType.repBased:
      case DrillType.timed:
      case DrillType.readAndReact:
        return false; // Always enabled or auto-complete
    }
  }
} 