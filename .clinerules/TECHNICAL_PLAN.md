# High-Level Technical Plan

This document outlines the architecture and technology choices for the Basketball Training App, evolving through its development phases.

## 1. Guiding Principles

- **Phased Rollout for Rapid Learning:** Launch an MVP quickly to validate core ideas before building complex features.
- **Build for Scale:** Choose technologies that are efficient for the MVP but can scale to support advanced AI features in the future.

## 2. Technology Stack

### MVP (Phase 1) Stack

- **Framework:** Flutter (for cross-platform development with a single codebase).
- **State Management:** Provider (for its simplicity and effectiveness in smaller-scale apps).
- **Local Storage:** A simple JSON file stored on the device's local documents directory via the `path_provider` package. This removes the need for a backend or user accounts in the initial dogfooding phase.
- **Data Source:** A local `workouts.json` file stored in the app's `assets` folder.

### Future Tech Stack Evolution

- **Backend (Phase 2+):** Firebase will be introduced to manage user authentication, cloud data storage (Firestore), and serverless logic (Cloud Functions).
- **On-Device AI (Phase 2+):** TensorFlow Lite (Android) and Core ML (iOS) will be used to run computer vision models for automated shot tracking directly on the user's device.
- **Cloud AI (Phase 3+):** The Gemini API will be integrated for the conversational AI Coach feature, allowing for dynamic workout generation and personalized feedback.

## 3. MVP Architecture

The MVP will use a simple, local-first architecture.

1.  **Data Loading:** The `WorkoutRepository` will be responsible for reading the `workouts.json` file from the app's assets.
2.  **State Management:** The `WorkoutState` service (using Provider) will manage the state of the active workout session, including the current drill, timers, and results as they are logged.
3.  **UI:** The screens will be built as Flutter widgets that listen to the `WorkoutState` and rebuild when data changes.
4.  **Data Persistence:** Upon workout completion, the `StorageService` will serialize the entire workout session object into JSON and save it to a file on the device's local storage. The Workout History screen will read from this file.