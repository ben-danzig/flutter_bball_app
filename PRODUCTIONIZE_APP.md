# Productionize App Checklist

This document tracks all the steps required before releasing the app to the public (e.g., Google Play Store, App Store).

---

## 1. Google Play Store Release: Generate Release SHA-1

- **Why:**
  - The release SHA-1 fingerprint is required for Google Sign-In and some Firebase features to work in your production (release) app.
- **How to generate:**
  1. Locate your release keystore (e.g., `my-release-key.jks`).
  2. Run the following command, replacing the path and alias as needed:
     ```sh
     keytool -list -v -keystore /path/to/your/release-key.jks -alias your-key-alias
     ```
     - You will be prompted for the keystore and key passwords.
  3. Copy the `SHA1:` value from the output.
  4. Go to the Firebase Console → Project Settings → Your apps → Android → Add fingerprint.
  5. Paste the SHA-1 and save.
- **Note:**
  - The debug SHA-1 is only for development. The release SHA-1 is required for production builds distributed via the Play Store.

---

## 2. [Add other productionization steps here]

- e.g., Set up app icons and splash screens
- e.g., Configure privacy policy and terms of service
- e.g., Enable ProGuard/obfuscation for release builds
- e.g., Set up crash reporting and analytics
- e.g., Test on real devices
- e.g., Review and update permissions
- e.g., Prepare Play Store listing (screenshots, description, etc.)

---

Add more steps as you go to ensure a smooth and professional release! 