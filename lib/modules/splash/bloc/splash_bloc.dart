import 'dart:async';
import 'dart:io';

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
        debugPrint('[SPLASH] 📱 No device ID found, registering device...');

        // Register the device
        final deviceId = await _registerDevice();

        if (deviceId != null) {
          debugPrint('[SPLASH] ✅ Device registered successfully: $deviceId');
        }
      } else {
        debugPrint('[SPLASH] ✅ Device already registered: $existingDeviceId');
        await Future.delayed(const Duration(milliseconds: 2000));
      }

      emit(NavigateToHomeActionState());
    } catch (e) {
      debugPrint('[SPLASH] ❌ Error during initialization: $e');

      // Still navigate to home even if registration fails
      // The app can retry registration later or work in offline mode
      await Future.delayed(const Duration(milliseconds: 2000));
      emit(NavigateToHomeActionState());
    }
  }

  Future<String?> _registerDevice() async {
    try {
      // Get app version
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version;

      // Generate a unique device ID based on actual device info
      final deviceId = await _generateDeviceId();

      // Get device location from configuration or generate default
      final location = DeviceConfig.getLocation();

      // Prepare registration data
      final registrationData = {
        'deviceId': deviceId,
        'location': location,
        'appVersion': appVersion,
      };

      debugPrint('[SPLASH] 📤 Registering device with data: $registrationData');

      // Call registration API
      final response = await _apiClient.postApi(
        ApiConstants.register,
        body: registrationData,
      );

      if (response != null && response.statusCode == 200) {
        // Save device ID to session
        await SessionManager.saveDeviceId(deviceId);

        debugPrint('[SPLASH] ✅ Device registered and saved: $deviceId');
        debugPrint('[SPLASH] 📍 Location: $location');

        return deviceId;
      } else {
        debugPrint(
          '[SPLASH] ⚠️ Registration failed with status: ${response?.statusCode}',
        );

        // Save device ID locally anyway so we can retry later
        await SessionManager.saveDeviceId(deviceId);

        debugPrint('[SPLASH] 💾 Device ID saved locally for retry');
        return deviceId;
      }
    } catch (e) {
      debugPrint('[SPLASH] ❌ Device registration error: $e');

      // Generate and save device ID locally for offline use
      try {
        final deviceId = await _generateDeviceId();
        await SessionManager.saveDeviceId(deviceId);
        debugPrint(
          '[SPLASH] 💾 Device ID saved locally for later registration: $deviceId',
        );
        return deviceId;
      } catch (saveError) {
        debugPrint('[SPLASH] ❌ Failed to save device ID: $saveError');
        return null;
      }
    }
  }

  Future<String> _generateDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;

        // Use Android ID (unique per device per app)
        final androidId = androidInfo.id;

        // Create a clean device ID
        final deviceId = 'TV-AND-${androidId.substring(0, 8).toUpperCase()}';

        debugPrint('[SPLASH] 📱 Generated Android device ID: $deviceId');
        debugPrint(
          '[SPLASH] 📱 Device: ${androidInfo.brand} ${androidInfo.model}',
        );

        return deviceId;
      } else {
        // Fallback for other platforms
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final deviceId =
            'TV-${timestamp.toString().substring(timestamp.toString().length - 8)}';

        debugPrint('[SPLASH] 📱 Generated fallback device ID: $deviceId');

        return deviceId;
      }
    } catch (e) {
      debugPrint('[SPLASH] ⚠️ Error getting device info, using fallback: $e');

      // Fallback: generate from timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return 'TV-${timestamp.toString().substring(timestamp.toString().length - 8)}';
    }
  }
}
