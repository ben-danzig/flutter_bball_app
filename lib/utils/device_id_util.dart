import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

Future<String> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();

  if (kIsWeb) {
    // Web: generate and persist a random ID
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('webDeviceId');
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString('webDeviceId', id);
    }
    return id;
  }

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor ?? 'unknown-ios';
  } else {
    // Fallback for other platforms
    return 'unknown-device';
  }
} 