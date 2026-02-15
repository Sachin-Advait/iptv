import 'package:flutter/material.dart';

/// Helper class to manage TV/Device ID configuration
/// This can be used to get the TV ID from various sources
class DashboardConfig {
  DashboardConfig._();

  /// Get TV ID from various sources (in priority order)
  /// 1. Session Manager (if you have a logged in device)
  /// 2. Device ID (using device_info_plus or similar)
  /// 3. Hardcoded default for testing
  static String getTvId() {
    // Option 1: From SessionManager (if you have one)
    // final tvId = SessionManager.getTvId();
    // if (tvId != null && tvId.isNotEmpty) {
    //   return tvId;
    // }

    // Option 2: From SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    // final tvId = prefs.getString('tv_id');
    // if (tvId != null && tvId.isNotEmpty) {
    //   return tvId;
    // }

    // Option 3: From device info
    // final deviceInfo = await DeviceInfoPlugin().androidInfo;
    // return deviceInfo.id ?? 'default_tv';

    // Option 4: Hardcoded for testing
    return 'tv_001'; // Replace with your actual TV ID
  }

  /// Set TV ID (call this during login or device registration)
  static Future<void> setTvId(String tvId) async {
    // Save to SessionManager
    // SessionManager.setTvId(tvId);

    // Or save to SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('tv_id', tvId);

    debugPrint('[DASHBOARD-CONFIG] TV ID set: $tvId');
  }

  /// Clear TV ID (call during logout)
  static Future<void> clearTvId() async {
    // SessionManager.clearTvId();
    // Or
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.remove('tv_id');

    debugPrint('[DASHBOARD-CONFIG] TV ID cleared');
  }
}

/// Example usage in your app:
///
/// 1. During device registration/login:
/// ```dart
/// await DashboardConfig.setTvId(responseData['tvId']);
/// ```
///
/// 2. In DashboardView initialization:
/// ```dart
/// final tvId = DashboardConfig.getTvId();
/// await _dashboardCubit.initializeWebSocket(tvId);
/// ```
///
/// 3. During logout:
/// ```dart
/// await DashboardConfig.clearTvId();
/// ```
