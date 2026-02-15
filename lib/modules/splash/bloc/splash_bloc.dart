import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/common/constants/api_constants.dart';
import 'package:oman_tv/common/utils/get_it.dart';
import 'package:oman_tv/modules/splash/view/device_config.dart';
import 'package:oman_tv/services/api_client.dart';
import 'package:oman_tv/services/session_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final ApiClient _apiClient = getIt<ApiClient>();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  SplashBloc() : super(SplashInitial()) {
    on<NavigateToNextEvent>(_goToNext);
  }

  Future<void> _goToNext(
    NavigateToNextEvent event,
    Emitter<SplashState> emit,
  ) async {
    try {
      // Check if device is already registered
      final existingDeviceId = SessionManager.getDeviceId();

      if (existingDeviceId.isEmpty) {
        debugPrint('[SPLASH] 📱 No saved device ID, registering device...');

        // Register the device
        final deviceId = await _registerDevice();

        if (deviceId != null) {
          debugPrint('[SPLASH] ✅ Device registered: $deviceId');
        }
      } else {
        debugPrint('[SPLASH] ✅ Device already registered: $existingDeviceId');
        await Future.delayed(const Duration(milliseconds: 2000));
      }

      emit(NavigateToHomeActionState());
    } catch (e) {
      debugPrint('[SPLASH] ❌ Error during initialization: $e');

      // Still navigate to home even if registration fails
      await Future.delayed(const Duration(milliseconds: 2000));
      emit(NavigateToHomeActionState());
    }
  }

  Future<String?> _registerDevice() async {
    try {
      // Get app version
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version;

      // Generate persistent device ID (survives reinstall)
      final deviceId = await _generateDeviceId();

      // Get device location from configuration
      final location = DeviceConfig.getLocation();

      // Prepare registration data
      final registrationData = {
        'deviceId': deviceId,
        'location': location,
        'appVersion': appVersion,
      };

      debugPrint('[SPLASH] 📤 Registering device: $registrationData');

      // Call registration API
      final response = await _apiClient.postApi(
        ApiConstants.register,
        body: registrationData,
      );

      if (response != null && response.statusCode == 200) {
        // Save device ID to session
        await SessionManager.saveDeviceId(deviceId);

        debugPrint('[SPLASH] ✅ Device registered successfully');
        debugPrint('[SPLASH] 📍 Location: $location');

        return deviceId;
      } else {
        debugPrint(
          '[SPLASH] ⚠️ Registration failed with status: ${response?.statusCode}',
        );

        // Save device ID locally anyway
        await SessionManager.saveDeviceId(deviceId);

        return deviceId;
      }
    } catch (e) {
      debugPrint('[SPLASH] ❌ Device registration error: $e');

      // Generate and save device ID locally for offline use
      try {
        final deviceId = await _generateDeviceId();
        await SessionManager.saveDeviceId(deviceId);
        debugPrint('[SPLASH] 💾 Device ID saved locally: $deviceId');
        return deviceId;
      } catch (saveError) {
        debugPrint('[SPLASH] ❌ Failed to save device ID: $saveError');
        return null;
      }
    }
  }

  /// Generates a persistent device ID for Android
  /// Uses Android ID which survives app reinstallation
  Future<String> _generateDeviceId() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;

      // Android ID is unique and persistent per device
      // This will be the SAME even after app reinstall
      final androidId = androidInfo.id;

      // Create readable device ID
      final deviceId = 'TV-AND-${androidId.substring(0, 8).toUpperCase()}';

      debugPrint('[SPLASH] 📱 Generated device ID: $deviceId');
      debugPrint(
        '[SPLASH] 📱 Device: ${androidInfo.brand} ${androidInfo.model}',
      );
      debugPrint('[SPLASH] 🔒 This ID survives app reinstall');

      return deviceId;
    } catch (e) {
      debugPrint('[SPLASH] ❌ Error getting device info: $e');

      // Fallback: use timestamp (will change on reinstall)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final deviceId =
          'TV-${timestamp.toString().substring(timestamp.toString().length - 8)}';

      debugPrint('[SPLASH] ⚠️ Using fallback device ID: $deviceId');

      return deviceId;
    }
  }
}
