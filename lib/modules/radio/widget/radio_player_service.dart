import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class RadioPlayerService {
  static final RadioPlayerService _instance = RadioPlayerService._internal();
  factory RadioPlayerService() => _instance;

  RadioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> play(String url) async {
    try {
      await _player.setVolume(1.0);
      await _player.play(UrlSource(url));
    } catch (e) {
      debugPrint('This is audio error---->>>>> $e');
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  bool get isPlaying => _player.state == PlayerState.playing;
}
