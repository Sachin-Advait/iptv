import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        "https://live.alarabiya.net/alarabiapublish/alarabiya.smil/playlist.m3u8",
      ),
    );

    _controller
        .initialize()
        .then((_) {
          setState(() {});
          _controller.setLooping(true);
          _controller.setVolume(1.0);
          _controller.play();
          _startAutoHide();
        })
        .catchError((e) {
          debugPrint("VIDEO INIT ERROR: $e");
        });
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // ----------------- Controls -----------------

  void _togglePlay() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
    _startAutoHide();
  }

  void _showUI() {
    setState(() {
      _showControls = true;
    });
    _startAutoHide();
  }

  void _hideUI() {
    setState(() {
      _showControls = false;
    });
  }

  void _startAutoHide() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  // ----------------- Seek -----------------

  void _seekBy(Duration offset) {
    final pos = _controller.value.position;
    final dur = _controller.value.duration;

    Duration target = pos + offset;
    if (target < Duration.zero) target = Duration.zero;
    if (target > dur) target = dur;

    _controller.seekTo(target);
    _showUI();
  }

  /// Dial pad seek (0–9)
  void _seekByPercent(int digit) {
    if (!_controller.value.isInitialized) return;

    final dur = _controller.value.duration;
    final percent = digit / 10; // 0.0 → 0%, 1 → 10%, ... 9 → 90%
    final target = dur * percent;

    _controller.seekTo(target);
    _showUI();
  }

  // ----------------- UI -----------------

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_showControls) {
          _hideUI(); // Netflix behavior
          return false;
        } else {
          return true; // exit screen
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: !_controller.value.isInitialized
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary,))
            : Focus(
                autofocus: true,
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent) {
                    final key = event.logicalKey;

                    // 🎮 OK / SELECT
                    if (key == LogicalKeyboardKey.select ||
                        key == LogicalKeyboardKey.enter ||
                        key == LogicalKeyboardKey.gameButtonA) {
                      if (!_showControls) {
                        _showUI();
                      } else {
                        _togglePlay();
                      }
                      return KeyEventResult.handled;
                    }

                    // 🔙 BACK handled by WillPopScope

                    // ⬅️➡️ DPAD SEEK
                    if (key == LogicalKeyboardKey.arrowRight) {
                      _seekBy(const Duration(seconds: 10));
                      return KeyEventResult.handled;
                    }

                    if (key == LogicalKeyboardKey.arrowLeft) {
                      _seekBy(const Duration(seconds: -10));
                      return KeyEventResult.handled;
                    }

                    // 🔢 DIAL PAD SEEK (0–9)
                    if (key == LogicalKeyboardKey.digit0) {
                      _seekByPercent(0);
                      return KeyEventResult.handled;
                    }
                    if (key == LogicalKeyboardKey.digit1) {
                      _seekByPercent(1);
                      return KeyEventResult.handled;
                    }
                    if (key == LogicalKeyboardKey.digit2) {
                      _seekByPercent(2);
                      return KeyEventResult.handled;
                    }
                    if (key == LogicalKeyboardKey.digit3) {
                      _seekByPercent(3);
                      return KeyEventResult.handled;
                    }
                    if (key == LogicalKeyboardKey.digit4) {
                      _seekByPercent(4);
                      return KeyEventResult.handled;
                    }
                    if (key == LogicalKeyboardKey.digit5) {
                      _seekByPercent(5);
                      return KeyEventResult.handled;
                    }
                    if (key == LogicalKeyboardKey.digit6) {
                      _seekByPercent(6);
                      return KeyEventResult.handled;
                    }
                    if (key == LogicalKeyboardKey.digit7) {
                      _seekByPercent(7);
                      return KeyEventResult.handled;
                    }
                    if (key == LogicalKeyboardKey.digit8) {
                      _seekByPercent(8);
                      return KeyEventResult.handled;
                    }
                    if (key == LogicalKeyboardKey.digit9) {
                      _seekByPercent(9);
                      return KeyEventResult.handled;
                    }
                  }

                  return KeyEventResult.ignored;
                },
                child: Stack(
                  children: [
                    // 🔥 VIDEO
                    SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),

                    // 🎚 SEEK BAR
                    if (_showControls)
                      Positioned(
                        bottom: 40,
                        left: 60,
                        right: 60,
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            playedColor: Colors.redAccent,
                            bufferedColor: Colors.white38,
                            backgroundColor: Colors.white12,
                          ),
                        ),
                      ),

                    // 🎛 CONTROLS
                    if (_showControls)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.35),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                size: 100,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _controller.value.isPlaying ? "PAUSE" : "PLAY",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
