import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/services/settings_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

void main() {
  setUp(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/settings.json');
    if (await file.exists()) {
      await file.delete();
    }
  });

  group('SettingsService', () {
    test('should have default values as true', () async {
      final settings = await SettingsService.create();
      
      expect(settings.announceDrillName, true);
      expect(settings.announceDrillDescription, true);
      expect(settings.announceDrillTargetMakes, true);
      expect(settings.playTimerSounds, true);
    });

    test('should update announceDrillName', () async {
      final settings = await SettingsService.create();
      
      await settings.setAnnounceDrillName(false);
      expect(settings.announceDrillName, false);
      
      await settings.setAnnounceDrillName(true);
      expect(settings.announceDrillName, true);
    });

    test('should update announceDrillDescription', () async {
      final settings = await SettingsService.create();
      
      await settings.setAnnounceDrillDescription(false);
      expect(settings.announceDrillDescription, false);
      
      await settings.setAnnounceDrillDescription(true);
      expect(settings.announceDrillDescription, true);
    });

    test('should update announceDrillTargetMakes', () async {
      final settings = await SettingsService.create();
      
      await settings.setAnnounceDrillTargetMakes(false);
      expect(settings.announceDrillTargetMakes, false);
      
      await settings.setAnnounceDrillTargetMakes(true);
      expect(settings.announceDrillTargetMakes, true);
    });

    test('should notify listeners when settings change', () async {
      final settings = await SettingsService.create();
      int notificationCount = 0;
      
      settings.addListener(() {
        notificationCount++;
      });
      
      await settings.setAnnounceDrillName(false);
      expect(notificationCount, 1);
      
      await settings.setAnnounceDrillDescription(false);
      expect(notificationCount, 2);
      
      await settings.setAnnounceDrillTargetMakes(false);
      expect(notificationCount, 3);

      await settings.setPlayTimerSounds(false);
      expect(notificationCount, 4);
    });

    test('should update playTimerSounds', () async {
      final settings = await SettingsService.create();
      
      await settings.setPlayTimerSounds(false);
      expect(settings.playTimerSounds, false);
      
      await settings.setPlayTimerSounds(true);
      expect(settings.playTimerSounds, true);
    });

    test('should persist playTimerSounds to settings.json', () async {
      final settings = await SettingsService.create();
      await settings.setPlayTimerSounds(false);

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/settings.json');
      expect(await file.exists(), true);
      final contents = await file.readAsString();
      final Map<String, dynamic> data = json.decode(contents);
      expect(data['playTimerSounds'], false);
    });

    test('should load playTimerSounds from existing settings.json', () async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/settings.json');
      await file.writeAsString('{"announceDrillName":true,"announceDrillDescription":true,"announceDrillTargetMakes":true,"playTimerSounds":false}');

      final loaded = await SettingsService.create();
      expect(loaded.playTimerSounds, false);
    });
  });
}