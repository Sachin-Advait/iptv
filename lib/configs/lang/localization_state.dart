// lib/bloc/localization/localization_state.dart
part of 'localization_cubit.dart';

class LocalizationState {
  final Locale locale;

  LocalizationState({required this.locale});

  LocalizationState copyWith({Locale? locale}) {
    return LocalizationState(locale: locale ?? this.locale);
  }
}
