# Tests Specification

This is the tests coverage details for the spec detailed in @.agent-os/specs/2025-09-20-workout-builder/spec.md

> Created: 2025-09-20
> Version: 1.0.0

## Test Coverage

### Unit Tests

**CustomWorkoutBlueprint**
- Serialization/deserialization to/from JSON with custom fields
- Validation of required fields and data types
- Duration calculation from drill configurations
- Equality comparison and hash code implementation

**WorkoutBuilderProvider**
- State management for draft workout creation
- Auto-save functionality for draft persistence
- Validation of workout configurations
- Reset and clear draft functionality

**CustomWorkoutRepository**
- CRUD operations for custom workout templates
- Local storage persistence with SharedPreferences
- Firestore synchronization with offline support
- Error handling for network failures and data corruption

**DrillLibraryService**
- Drill categorization and filtering logic
- Search functionality with text matching
- Drill configuration validation by type
- Default parameter generation for drill types

### Integration Tests

**Workout Builder Flow**
- Complete workflow from creation to saving custom workout
- Navigation between builder screens with state persistence
- Form validation and error handling across screens
- Draft auto-save and recovery after app restart

**Custom Workout Execution**
- Created workouts execute properly in active workout system
- Audio guidance works correctly with custom drill sequences
- Progress tracking and result logging for custom workouts
- Pause/resume functionality maintains state correctly

**Data Synchronization**
- Custom workouts sync between local storage and Firestore
- Conflict resolution when same workout modified on multiple devices
- Offline capability with proper sync when connection restored
- Error handling for sync failures with user feedback

**Library Integration**
- Custom workouts appear correctly in main workout library
- Filtering and sorting works with both custom and pre-built workouts
- Edit/delete operations work seamlessly from library view
- Duplicate detection and handling for workout names

### Widget Tests

**WorkoutBuilderScreen**
- Proper rendering of step-by-step builder interface
- Form validation messages display correctly
- Navigation between steps maintains form state
- Save/cancel buttons work with appropriate confirmations

**DrillLibraryScreen**
- Drill list renders correctly with proper categorization
- Search and filter functionality updates list appropriately
- Drill selection state management works correctly
- Loading states and empty states render properly

**DrillConfigurationWidget**
- Dynamic form rendering based on drill type
- Real-time validation of configuration parameters
- Parameter constraints enforced (min/max values)
- Default value population and user input handling

**WorkoutPreviewWidget**
- Accurate display of workout summary information
- Duration calculation reflects actual drill configurations
- Drill count and type distribution shown correctly
- Edit functionality navigates back to appropriate builder step

### Feature Tests

**End-to-End Workout Creation**
- User can create complete custom workout from start to finish
- Created workout saves successfully and appears in library
- Workout can be started and completed successfully
- Results are tracked and saved properly

**Template Management Workflow**
- User can edit existing custom workout templates
- Changes are saved and reflected in library immediately
- User can duplicate workouts to create variations
- Delete functionality removes workout from all locations

**Drill Library Management**
- User can browse complete drill library with smooth scrolling
- Search finds drills by name, description, and type
- Filter combinations work correctly (type + category)
- Drill details and configurations display accurately

### Mocking Requirements

**SharedPreferences Mock**
- Mock local storage for draft persistence testing
- Simulate storage failures and recovery scenarios
- Test data migration and format compatibility

**Firestore Mock**
- Mock cloud storage operations for custom workouts
- Simulate network failures and offline scenarios
- Test data synchronization and conflict resolution

**WorkoutState Mock**
- Mock active workout execution for integration testing
- Simulate various workout completion scenarios
- Test custom workout compatibility with existing system

**Navigation Mock**
- Mock route navigation for builder flow testing
- Test back navigation with unsaved changes
- Simulate deep linking to builder screens

### Performance Tests

**Large Drill Library Rendering**
- Test smooth scrolling with 100+ drill items
- Memory usage remains stable during extended browsing
- Search performance with large dataset

**Workout Validation Performance**
- Real-time validation responds within 100ms
- Form updates don't cause UI lag or freezing
- Complex workout configurations validate efficiently

**Storage Operation Performance**
- Local save operations complete within 200ms
- Background sync doesn't impact UI responsiveness
- Bulk operations (import/export) handle appropriately


