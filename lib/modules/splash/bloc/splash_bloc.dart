import 'dart:async';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/common/constants/api_constants.dart';
import 'package:oman_tv/common/utils/get_it.dart';
import 'package:oman_tv/models/regsitration_model.dart';
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
      final existingDeviceId = SessionManager.getDeviceId();
      final existingTvId = SessionManager.getTvId();

      if (existingDeviceId.isEmpty || existingTvId.isEmpty) {
        debugPrint('[SPLASH] 📱 No saved device/tv ID, registering device...');
        final tvId = await _registerDevice();

        if (tvId != null) {
          debugPrint('[SPLASH] ✅ Device registered, TV ID: $tvId');
        }
      } else {
        debugPrint('[SPLASH] ✅ Device already registered');
        debugPrint('[SPLASH] 🆔 TV ID: $existingTvId');
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

  Future<String?> _registerDevice({int maxAttempts = 5}) async {
    int attempt = 0;

    while (attempt < maxAttempts) {
      attempt++;
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        final appVersion = packageInfo.version;

        final localDeviceId = await _generateDeviceId();
        final location = "Defualt Location";

        final view = PlatformDispatcher.instance.views.first;

        final physicalSize = view.physicalSize;
        final devicePixelRatio = view.devicePixelRatio;

        final logicalWidth = physicalSize.width / devicePixelRatio;
        final logicalHeight = physicalSize.height / devicePixelRatio;

        final orientation = logicalWidth > logicalHeight
            ? "horizontal"
            : "vertical";

        final size =
            "${physicalSize.width.toInt()}X${physicalSize.height.toInt()}";

        final registrationData = {
          'deviceId': localDeviceId,
          'location': location,
          'appVersion': appVersion,
          "orientation": orientation,
          "size": size,
        };

        debugPrint(
          '[SPLASH] 📤 Registering device (attempt $attempt/$maxAttempts): $registrationData',
        );

        final response = await _apiClient.postApi(
          ApiConstants.register,
          body: registrationData,
        );

        if (response != null && response.statusCode == 200) {
          final model = RegistrationModel.fromJson(response.data);

          final tvId = model.data.id.toString();
          final serverDeviceId = model.data.deviceId;

          if (tvId.isNotEmpty) {
            await SessionManager.saveTvId(tvId);
            await SessionManager.saveDeviceId(serverDeviceId);

            debugPrint('[SPLASH] ✅ Device registered');
            debugPrint('[SPLASH] 🆔 TV ID: $tvId');
            return tvId;
          }
        }

        debugPrint('[SPLASH] ⚠️ Invalid response, retrying...');
      } catch (e) {
        debugPrint('[SPLASH] ❌ Registration attempt $attempt failed: $e');
      }

      // ⏳ Backoff before retry (2s, 4s, 6s…)
      final delay = Duration(seconds: 2 * attempt);
      debugPrint('[SPLASH] ⏳ Retrying in ${delay.inSeconds}s...');
      await Future.delayed(delay);
    }

    debugPrint('[SPLASH] ⛔ Registration failed after $maxAttempts attempts');
    return null;
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
