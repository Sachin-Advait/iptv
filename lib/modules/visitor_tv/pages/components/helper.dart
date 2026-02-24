import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:oman_tv/models/display_token.dart';
import 'package:oman_tv/services/google_speech.dart';

class Helper {
  static String getFormattedDate(DateTime date, bool isRTL) {
    if (isRTL) {
      final arabicMonths = {
        'January': 'يناير',
        'February': 'فبراير',
        'March': 'مارس',
        'April': 'أبريل',
        'May': 'مايو',
        'June': 'يونيو',
        'July': 'يوليو',
        'August': 'أغسطس',
        'September': 'سبتمبر',
        'October': 'أكتوبر',
        'November': 'نوفمبر',
        'December': 'ديسمبر',
      };

      final arabicDays = {
        'Monday': 'الاثنين',
        'Tuesday': 'الثلاثاء',
        'Wednesday': 'الأربعاء',
        'Thursday': 'الخميس',
        'Friday': 'الجمعة',
        'Saturday': 'السبت',
        'Sunday': 'الأحد',
      };

      final englishDay = intl.DateFormat('EEEE').format(date);
      final englishMonth = intl.DateFormat('MMMM').format(date);

      return '${arabicDays[englishDay] ?? englishDay}، ${date.day} ${arabicMonths[englishMonth] ?? englishMonth}، ${date.year}';
    } else {
      return intl.DateFormat('EEEE, MMMM d, y').format(date);
    }
  }

  static Future<void> playAnnouncement(
    DisplayToken latestToken,
    AudioPlayer player,
    PiperTtsService tts,
  ) async {
    try {
      // Play notification sound
      await player.play(AssetSource('audio/glass-sms.mp3'));
      await player.onPlayerComplete.first;

      // Arabic announcement
      final arabicText = buildAnnouncementArabic(latestToken);
      final arabicTtsPath = await tts.generateArabic(arabicText);
      await player.play(DeviceFileSource(arabicTtsPath));
      await player.onPlayerComplete.first;

      // English announcement
      final englishText = buildAnnouncementEnglish(latestToken);
      final englishTtsPath = await tts.generateEnglish(englishText);
      await player.play(DeviceFileSource(englishTtsPath));
    } catch (e) {
      debugPrint('[TV-ANNOUNCE] ❌ Announcement failed: $e');
    }
  }
}

String buildAnnouncementArabic(DisplayToken token) {
  return "يرجى التوجه إلى ${token.counter}. رقم ${token.token}";
}

String buildAnnouncementEnglish(DisplayToken token) {
  return "Please proceed to ${token.counter}. Token ${token.token}";
}
