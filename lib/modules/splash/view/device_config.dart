import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

/// Device Configuration Manager
/// Handles custom location names and device-specific settings
class DeviceConfig {
  static final _storage = GetStorage();

  static const String _locationKey = 'device_location';
  static const String _deviceNameKey = 'device_name';

  /// Set custom location for the device
  /// Example: "Reception Desk", "Lobby TV", "Conference Room 1"
  static Future<void> setLocation(String location) async {
    await _storage.write(_locationKey, location);
    debugPrint('[DEVICE-CONFIG] Location set: $location');
  }

  /// Get custom location for the device
  /// Returns saved location or generates default from device info
  static String getLocation() {
    final location = _storage.read<String?>(_locationKey);

    if (location != null && location.isNotEmpty) {
      return location;
    }

    // Return default location if not set
    return 'Default Location';
  }

  /// Set custom device name
  /// Example: "Main TV", "Entrance Display", "Waiting Room Screen"
  static Future<void> setDeviceName(String name) async {
    await _storage.write(_deviceNameKey, name);
    debugPrint('[DEVICE-CONFIG] Device name set: $name');
  }

  /// Get custom device name
  static String getDeviceName() {
    final name = _storage.read<String?>(_deviceNameKey);

    if (name != null && name.isNotEmpty) {
      return name;
    }

    return 'TV Display';
  }

  /// Check if device has been configured
  static bool isConfigured() {
    final location = _storage.read<String?>(_locationKey);
    return location != null && location.isNotEmpty;
  }

  /// Clear all device configuration
  static Future<void> clearConfig() async {
    await _storage.remove(_locationKey);
    await _storage.remove(_deviceNameKey);
    debugPrint('[DEVICE-CONFIG] Configuration cleared');
  }
}
