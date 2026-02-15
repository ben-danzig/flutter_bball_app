import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bball_app/screens/settings/settings_screen.dart';
import 'package:flutter_bball_app/services/settings_service.dart';

void main() {
  testWidgets('SettingsScreen shows and reflects Timer Sound Effects state', (tester) async {
    final settings = await SettingsService.create();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<SettingsService>.value(
          value: settings,
          child: const SettingsScreen(),
        ),
      ),
    );

    // Initially ON by default
    expect(find.text('Timer Sound Effects'), findsOneWidget);
    final switchFinder = find.byKey(const Key('settings_timer_sound_effects_switch'));
    expect(switchFinder, findsOneWidget);
    expect(tester.widget<Switch>(switchFinder).value, true);

    // Programmatically update setting and verify UI updates
    await settings.setPlayTimerSounds(false);
    await tester.pump();
    expect(tester.widget<Switch>(switchFinder).value, false);
  });
}


