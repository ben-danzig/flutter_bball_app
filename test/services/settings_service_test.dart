import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/services/settings_service.dart';

void main() {
  group('SettingsService', () {
    test('should have default values as true', () async {
      final settings = await SettingsService.create();
      
      expect(settings.announceDrillName, true);
      expect(settings.announceDrillDescription, true);
      expect(settings.announceDrillTargetMakes, true);
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
    });
  });
}