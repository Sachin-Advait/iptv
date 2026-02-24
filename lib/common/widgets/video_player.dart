import 'package:flutter/material.dart';
import 'package:flutter_multicast_lock/flutter_multicast_lock.dart';
import 'package:flutter_vlc_player_16kb/flutter_vlc_player.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';

class VideoView extends StatefulWidget {
  final String videoUrl;

  const VideoView({super.key, required this.videoUrl});

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  VlcPlayerController? _controller;
  final _multicastLock = FlutterMulticastLock();

  bool _multicastLockHeld = false;
  bool _isLoading = true;
  bool _hasError = false;

  String _status = "Starting...";

  @override
  void initState() {
    super.initState();
    _startPlayback();
  }

  Future<void> _startPlayback() async {
    final url = widget.videoUrl.trim();

    try {
      // Acquire multicast lock only for UDP/RTP streams
      if (_isUdp(url)) {
        try {
          await _multicastLock.acquireMulticastLock();
          _multicastLockHeld = true;
        } catch (e) {
          _setError("Multicast permission denied. Cannot play this stream.");
          return;
        }
      }

      final options = VlcPlayerOptions(
        advanced: VlcAdvancedOptions([VlcAdvancedOptions.networkCaching(500)]),
        extras: const [
          '--clock-jitter=0',
          '--clock-synchro=0',
          '--no-drop-late-frames',
          '--no-skip-frames',
        ],
      );

      final ctrl = VlcPlayerController.network(
        url,
        hwAcc: HwAcc.auto,
        autoPlay: true,
        options: options,
      );

      ctrl.addListener(() {
        final value = ctrl.value;

        if (!mounted) return;

        // 🔄 Buffering
        if (value.isBuffering) {
          if (!_isLoading) {
            setState(() {
              _isLoading = true;
              _status = "Buffering...";
            });
          }
        }

        // ▶ Playing
        if (value.isPlaying) {
          if (_isLoading) {
            setState(() {
              _isLoading = false;
              _status = "";
            });
          }
        }

        // ❌ Error
        if (value.hasError) {
          final error = value.errorDescription;

          if (error.contains("403") ||
              error.toLowerCase().contains("forbidden")) {
            _setError(
              "⛔ Access denied (403). You are not authorized to play this stream.",
            );
          } else if (error.toLowerCase().contains("404")) {
            _setError("❌ Stream not found (404).");
          } else {
            _setError("Playback error: $error");
          }
        }
      });

      setState(() {
        _controller = ctrl;
        _isLoading = true;
        _hasError = false;
        _status = "Loading stream...";
      });
    } catch (e) {
      _setError("❌ Failed to start playback: $e");
    }
  }

  void _setError(String message) {
    debugPrint("[VIDEO ERROR] $message");

    if (!mounted) return;

    setState(() {
      _status = message;
      _isLoading = false;
      _hasError = true;
      _controller?.stop();
      _controller?.dispose();
      _controller = null;
    });
  }

  bool _isUdp(String url) {
    final u = url.toLowerCase();
    return u.startsWith("udp://") || u.startsWith("rtp://");
  }

  @override
  void dispose() {
    _controller?.stop();
    _controller?.dispose();

    if (_multicastLockHeld) {
      _multicastLock.releaseMulticastLock();
      _multicastLockHeld = false;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🎥 Video Player
          if (ctrl != null && !_hasError)
            SizedBox.expand(
              child: VlcPlayer(
                controller: ctrl,
                aspectRatio: ctrl.value.aspectRatio == 0
                    ? 16 / 9
                    : ctrl.value.aspectRatio,
                placeholder: const SizedBox(),
              ),
            ),

          // 🔄 Loading / Buffering
          if (_isLoading && !_hasError)
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      style: context.semiBold.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          // ❌ Error State
          if (_hasError)
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _status,
                        textAlign: TextAlign.center,
                        style: context.semiBold.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
