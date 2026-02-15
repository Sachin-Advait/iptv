// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class SessionManager {
  static final _userStorage = GetStorage();

  static const String _deviceId = 'DeviceId ID';

  static Future<void> saveDeviceId(String deviceId) async {
    await _userStorage.write(_deviceId, deviceId);
    debugPrint("DeviceId saved ==> $deviceId.");
  }

  static String getDeviceId() {
    String DeviceId = _userStorage.read<String?>(_deviceId) ?? '';
    debugPrint("DeviceId Id ==> $DeviceId.");
    return DeviceId;
  }

  static void clearSession() {
    _userStorage.erase();
    debugPrint("Session Cleared.");
  }
}
