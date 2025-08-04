# Authentication Setup

This document describes the authentication system implemented in the Basketball Trainer app.

## Features

- **Email/Password Authentication**: Users can sign up and sign in with email and password
- **Google Sign-In**: Users can sign in using their Google account
- **Password Reset**: Users can reset their password via email
- **User Profiles**: User data is stored in Firestore with additional profile information
- **Automatic Session Management**: Users stay signed in until they explicitly sign out

## Architecture

### Services

- **AuthService**: Handles all authentication operations using Firebase Auth
- **UserRepository**: Manages user profile data in Firestore

### Screens

- **LoginScreen**: Email/password and Google sign-in
- **SignUpScreen**: New user registration
- **ForgotPasswordScreen**: Password reset functionality
- **AuthWrapper**: Routes users based on authentication state
- **LoadingScreen**: Shown while checking authentication status

### Models

- **UserProfile**: Stores additional user information beyond Firebase Auth data

## Setup Requirements

### Firebase Configuration

1. Enable Firebase Authentication in your Firebase console
2. Enable Email/Password authentication
3. Enable Google Sign-In authentication
4. Configure Google Sign-In for your platforms (iOS/Android)

### Dependencies

The following dependencies are required:

```yaml
dependencies:
  firebase_auth: ^4.17.2
  google_sign_in: ^6.2.1
  cloud_firestore: ^4.17.2
```

### Platform Configuration

#### Android

1. Add your `google-services.json` file to `android/app/`
2. Configure Google Sign-In in your Firebase console
3. Add SHA-1 fingerprint to Firebase project settings

#### iOS

1. Add your `GoogleService-Info.plist` file to `ios/Runner/`
2. Configure Google Sign-In in your Firebase console
3. Update `ios/Runner/Info.plist` with URL schemes

## Usage

### Sign Up

```dart
final authService = context.read<AuthService>();
await authService.signUpWithEmailAndPassword(email, password);
```

### Sign In

```dart
final authService = context.read<AuthService>();
await authService.signInWithEmailAndPassword(email, password);
```

### Google Sign In

```dart
final authService = context.read<AuthService>();
await authService.signInWithGoogle();
```

### Sign Out

```dart
final authService = context.read<AuthService>();
await authService.signOut();
```

### Password Reset

```dart
final authService = context.read<AuthService>();
await authService.sendPasswordResetEmail(email);
```

## User Profile Management

User profiles are automatically created when users sign up or sign in for the first time. The profile includes:

- User ID (from Firebase Auth)
- Email address
- Display name (if available)
- Profile photo URL (if available)
- Creation timestamp
- Last login timestamp
- User preferences

## Security Rules

Make sure to configure appropriate Firestore security rules for the `users` collection:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Error Handling

The authentication system includes comprehensive error handling for common scenarios:

- Invalid email format
- Weak passwords
- User not found
- Wrong password
- Email already in use
- Network errors
- Account disabled

All errors are displayed to users via SnackBar notifications with appropriate error messages. 