# Building and Distributing the APK via Firebase App Distribution

This guide explains how to build your Flutter app for Android and distribute the APK using Firebase App Distribution.

---

## Prerequisites
- Flutter SDK installed
- Firebase CLI installed (`firebase --version`)
- Logged in to Firebase (`firebase login`)
- Your project is set up with Firebase and the Android app is registered

---

## 1. Build the APK

Run the following command in your project root to build a release APK:

```bash
flutter build apk --release
```

- The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

---

## 2. Verify Firebase CLI & Project

Check that Firebase CLI is installed and you are logged in:

```bash
firebase --version
firebase projects:list
```

Ensure your project is selected (should show your project in the list, e.g. `flutter-bball-app`).

---

## 3. Check Android App Registration

List registered Android apps in your Firebase project:

```bash
firebase apps:list android
```

- Note the App ID for your Android app (e.g. `1:758737339378:android:aab23855bbbe3ffe75a16b`).

---

## 4. (Optional) Create a Distribution Group

If you don't have a testers group, create one:

```bash
firebase appdistribution:groups:create "Testers" testers
```

---

## 5. Distribute the APK

Upload and distribute your APK to Firebase App Distribution:

```bash
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:758737339378:android:aab23855bbbe3ffe75a16b \
  --groups testers \
  --release-notes "Added login logic"
```

- Replace the `--app` value with your actual App ID if different.
- Update `--release-notes` as needed.

---

## 6. Add Testers (Optional)

Add testers to your group:

```bash
firebase appdistribution:testers:add --group testers email@example.com
```

---

## 7. Share and Monitor
- Testers will receive an email invitation to download and test your app.
- You can view releases and feedback in the [Firebase Console](https://console.firebase.google.com/project/flutter-bball-app/appdistribution/app/android:com.example.flutter_bball_app/releases/).

---

## References
- [Firebase App Distribution Docs](https://firebase.google.com/docs/app-distribution)
- [Flutter Build APK Docs](https://docs.flutter.dev/deployment/android) 