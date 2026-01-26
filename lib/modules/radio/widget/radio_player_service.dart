import 'package:just_audio/just_audio.dart';

class RadioPlayerService {
  static final RadioPlayerService _instance = RadioPlayerService._internal();
  factory RadioPlayerService() => _instance;

  RadioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> play(String url) async {
    await _player.setUrl(url);
    _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  bool get isPlaying => _player.playing;
}
