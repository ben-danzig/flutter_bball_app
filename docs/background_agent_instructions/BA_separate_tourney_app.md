
## Cursor Agent Instructions: Add Danzig Cup Sub-App with Scoreboard Look Theme

### 1. Create the Danzig Cup App Shell

- Create a new directory: `lib/danzig_cup_app/`
- Create a new file: `lib/danzig_cup_app/danzig_cup_app.dart`
- In this file, implement a `DanzigCupApp` widget that uses its own `MaterialApp` (with `debugShowCheckedModeBanner: false`).
- The home of this app should be a `DanzigCupHome` widget.
- `DanzigCupHome` should be a `StatefulWidget` with a `Scaffold` that includes:
  - An `AppBar` with the title "Danzig Cup 2v2 Tournament".
  - A `Drawer` (hamburger menu) with two `ListTile` items:
    - "Player Register" (with `Icons.person_add`)
    - "Tournament Manager" (with `Icons.sports_basketball`)
  - The body should display a different widget based on the selected menu item (for now, just use `Center(child: Text(...))` for each).
- The drawer should close after a menu item is selected.

### 2. Add a Button to Launch the Danzig Cup App

- In your main app, add an `ElevatedButton` (or similar) to the home screen (e.g., `lib/screens/home_screen.dart`).
- The button should be labeled "Go to Danzig Cup 2v2 Tournament App".
- When pressed, it should use `Navigator.push` to open the `DanzigCupApp` widget from `lib/danzig_cup_app/danzig_cup_app.dart`.

### 3. Ensure Shared Backend/Services Are Accessible

- The new Danzig Cup app should be able to import and use any existing models, repositories, or services from the main app.
- No changes are needed unless you use a global state management solution (like Provider, Riverpod, etc.) that is only provided in the main app's widget tree. If so, ensure providers are accessible to both apps.

### 4. Apply a "Scoreboard Look" Theme to the Danzig Cup App

- In `lib/danzig_cup_app/danzig_cup_app.dart`, define a custom `ThemeData` for the Danzig Cup app to evoke a digital scoreboard vibe:
  - **Background:** Black or very dark gray (`#111111` or `#181818`)
  - **Accent/Primary:** Neon green (`#39FF14`), neon red (`#FF073A`), or bright yellow (`#FFD600`)
  - **Text:** White or bright colors for contrast
  - **AppBar:** Use dark background with neon accent for title
  - **Font:** Optionally, use a digital/LED font such as [Orbitron](https://fonts.google.com/specimen/Orbitron) from Google Fonts for headings or timer displays
- Example theme code to use in the Danzig Cup app:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData scoreboardTheme = ThemeData(
  scaffoldBackgroundColor: Color(0xFF111111),
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF39FF14), // Neon green
    secondary: Color(0xFF181818), // Very dark gray
    background: Color(0xFF111111),
    onPrimary: Colors.black,
    onSecondary: Colors.white,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF181818),
    foregroundColor: Color(0xFF39FF14),
    titleTextStyle: GoogleFonts.orbitron(
      color: Color(0xFF39FF14),
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: GoogleFonts.orbitronTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Color(0xFF39FF14),
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: Color(0xFF181818),
  ),
  iconTheme: IconThemeData(color: Color(0xFF39FF14)),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF39FF14),
      foregroundColor: Colors.black,
      textStyle: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
    ),
  ),
);
```

- In your `DanzigCupApp` widget, set `theme: scoreboardTheme`.

- Add `google_fonts` to your `pubspec.yaml` dependencies if not already present.

### 5. Testing

- After implementation, run the app.
- Verify that:
  - The new button appears on the home screen.
  - Pressing the button opens a new "app" with a hamburger menu.
  - The menu allows switching between "Player Register" and "Tournament Manager" screens.
  - The Danzig Cup app uses the scoreboard look theme and looks visually separate from the main app.

---

## Example File Structure After Changes

```
lib/
  danzig_cup_app/
    danzig_cup_app.dart
  screens/
    home_screen.dart  // (button added here)
  // ...other files unchanged
```

---

**Summary:**  
Implement a new sub-app in `lib/danzig_cup_app/danzig_cup_app.dart` with its own navigation and hamburger menu. Add a button in your main app to launch it. Apply a "scoreboard look" theme using dark backgrounds and neon accents, and optionally a digital font. Ensure both apps can share backend/services as needed.