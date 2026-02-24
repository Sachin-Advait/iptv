// lib/bloc/localization/localization_cubit.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'localization_state.dart';

class LocalizationCubit extends Cubit<LocalizationState> {
  LocalizationCubit()
    : super(LocalizationState(locale: const Locale('en', 'US')));

  Timer? _rotationTimer;
  Map<String, String> _englishStrings = {};
  Map<String, String> _arabicStrings = {};

  @override
  Future<void> close() {
    _rotationTimer?.cancel();
    return super.close();
  }

  Future<void> initialize() async {
    // Load both languages
    await _loadLanguages();

    // Start language rotation
    _startLanguageRotation();
  }

  Future<void> _loadLanguages() async {
    try {
      // Load English
      final englishJson = await rootBundle.loadString('assets/lang/en.json');
      final Map<String, dynamic> englishMap = json.decode(englishJson);
      _englishStrings = englishMap.map((key, value) {
        return MapEntry(key.toString(), value.toString());
      });

      // Load Arabic
      final arabicJson = await rootBundle.loadString('assets/lang/ar.json');
      final Map<String, dynamic> arabicMap = json.decode(arabicJson);
      _arabicStrings = arabicMap.map((key, value) {
        return MapEntry(key.toString(), value.toString());
      });
    } catch (e) {
      debugPrint('Error loading languages: $e');
      // Initialize with empty maps to avoid crashes
      _englishStrings = {};
      _arabicStrings = {};
    }
  }

  void _startLanguageRotation() {
    _rotationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final newLocale = state.locale.languageCode == 'en'
          ? const Locale('ar', 'SA')
          : const Locale('en', 'US');

      emit(state.copyWith(locale: newLocale));
    });
  }

  String translate(String key) {
    if (state.locale.languageCode == 'ar') {
      return _arabicStrings[key] ?? key;
    } else {
      return _englishStrings[key] ?? key;
    }
  }

  // Manual control methods (optional)
  void setLanguage(Locale locale) {
    _rotationTimer?.cancel();
    emit(state.copyWith(locale: locale));
  }

  void resumeRotation() {
    _startLanguageRotation();
  }
}

// lib/extensions/localization_extension.dart
extension LocalizationExtension on BuildContext {
  String tr(String key) => read<LocalizationCubit>().translate(key);

  Locale get currentLocale => watch<LocalizationCubit>().state.locale;
}
