import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SettingsService extends ChangeNotifier {
  static const String _settingsFileName = 'settings.json';
  
  // Audio settings
  bool _announceDrillName = true;
  bool _announceDrillDescription = true;
  bool _announceDrillTargetMakes = true;
  bool _playTimerSounds = true;

  // Getters
  bool get announceDrillName => _announceDrillName;
  bool get announceDrillDescription => _announceDrillDescription;
  bool get announceDrillTargetMakes => _announceDrillTargetMakes;
  bool get playTimerSounds => _playTimerSounds;

  SettingsService() {
    _loadSettings();
  }
  static Future<SettingsService> create() async {
    final service = SettingsService();
    await service._loadSettings();
    return service;
  }

  Future<void> _loadSettings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_settingsFileName');
      
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final Map<String, dynamic> data = json.decode(jsonString);
        
        _announceDrillName = data['announceDrillName'] ?? true;
        _announceDrillDescription = data['announceDrillDescription'] ?? true;
        _announceDrillTargetMakes = data['announceDrillTargetMakes'] ?? true;
        _playTimerSounds = data['playTimerSounds'] ?? true;
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_settingsFileName');
      
      final Map<String, dynamic> data = {
        'announceDrillName': _announceDrillName,
        'announceDrillDescription': _announceDrillDescription,
        'announceDrillTargetMakes': _announceDrillTargetMakes,
        'playTimerSounds': _playTimerSounds,
      };
      
      await file.writeAsString(json.encode(data));
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<void> setAnnounceDrillName(bool value) async {
    _announceDrillName = value;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setAnnounceDrillDescription(bool value) async {
    _announceDrillDescription = value;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setAnnounceDrillTargetMakes(bool value) async {
    _announceDrillTargetMakes = value;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setPlayTimerSounds(bool value) async {
    _playTimerSounds = value;
    notifyListeners();
    await _saveSettings();
  }
}