import 'package:flutter/material.dart';

/// A full-screen pop-up pushed from the admin portal.
class TvNotification {
  final int id;
  final String title;
  final String? message;
  final String
  category; // EMERGENCY / WARNING / INFO / ANNOUNCEMENT / CELEBRATION
  final int durationSeconds;
  final bool playSound;
  final bool addedToAnnouncements;

  const TvNotification({
    required this.id,
    required this.title,
    this.message,
    required this.category,
    required this.durationSeconds,
    required this.playSound,
    this.addedToAnnouncements = false,
  });

  factory TvNotification.fromJson(Map<String, dynamic> json) {
    return TvNotification(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      message: json['message'] as String?,
      category: (json['category'] as String? ?? 'INFO').toUpperCase(),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 15,
      playSound: json['playSound'] as bool? ?? true,
      addedToAnnouncements: json['addedToAnnouncements'] as bool? ?? false,
    );
  }
}

/// Holds the notification currently on screen. The socket feeds it and
/// [TvNotificationOverlay] shows it on top of every page.
class TvNotificationController {
  TvNotificationController._();

  static final TvNotificationController instance = TvNotificationController._();

  final ValueNotifier<TvNotification?> current = ValueNotifier(null);

  /// Handles a socket event: {action: SHOW | CANCEL, id, ...}
  void handleEvent(Map<String, dynamic> event) {
    final action = (event['action'] as String? ?? 'SHOW').toUpperCase();
    if (action == 'CANCEL') {
      if (current.value?.id == (event['id'] as num?)?.toInt()) {
        dismiss();
      }
      return;
    }
    // A newer notification replaces whatever is showing
    current.value = TvNotification.fromJson(event);
  }

  void dismiss() => current.value = null;
}
