import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with TickerProviderStateMixin {
  late final Player _player;
  late final VideoController _videoController;

  late AnimationController _scaleVideoAnimationController;
  Animation<double> _scaleVideoAnimation = const AlwaysStoppedAnimation<double>(
    1.0,
  );

  double _lastZoomGestureScale = 1.0;

  @override
  void initState() {
    super.initState();

    MediaKit.ensureInitialized();
    _forceLandscape();

    _scaleVideoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 125),
      vsync: this,
    );

    _player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 32 * 1024 * 1024, // stable buffering
      ),
    );

    _videoController = VideoController(_player);

    /// ▶️ Normal MP4 (replace with multicast when needed)
    _player.open(
      Media(
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",

        /// 🔴 Multicast example:
        /// "udp://@239.0.0.1:1234",
      ),
      play: false, // no autoplay bug
    );
  }

  Future<void> _forceLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _forcePortrait() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  @override
  void dispose() {
    _forcePortrait();
    _player.dispose();
    _scaleVideoAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              if (_player.state.playing) {
                _player.pause();
              } else {
                _player.play();
              }
            },
            onScaleUpdate: (details) {
              _lastZoomGestureScale = details.scale;
            },
            onScaleEnd: (details) {
              if (_lastZoomGestureScale > 1.0) {
                _scaleVideoAnimation = Tween<double>(
                  begin: 1.0,
                  end: 1.25,
                ).animate(_scaleVideoAnimationController);
                _scaleVideoAnimationController.forward(from: 0);
              } else if (_lastZoomGestureScale < 1.0) {
                _scaleVideoAnimation = Tween<double>(
                  begin: 1.25,
                  end: 1.0,
                ).animate(_scaleVideoAnimationController);
                _scaleVideoAnimationController.forward(from: 0);
              }
              _lastZoomGestureScale = 1.0;
            },
            child: Stack(
              children: [
                Container(color: Colors.black),
                Center(
                  child: ScaleTransition(
                    scale: _scaleVideoAnimation,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Video(
                        controller: _videoController,
                        fit: BoxFit.contain,
                        controls: NoVideoControls, // clean fullscreen
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 20,
                  left: 20,
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
