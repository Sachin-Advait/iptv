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
  String _status = "Starting...";

  @override
  void initState() {
    super.initState();
    try {
      _startPlayback();
    } catch (e) {
      throw Exception('1. App crashed due to $e');
    }
  }

  Future<void> _startPlayback() async {
    final url = widget.videoUrl.trim();

    try {
      // Acquire multicast lock only for multicast/udp streams (Wi-Fi use case)
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
        advanced: VlcAdvancedOptions([VlcAdvancedOptions.networkCaching(300)]),
        extras: [
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
        _status = "Loading stream...";
      });
    } catch (e) {
      _setError("❌ Failed to start playback: $e");
    }
  }

  void _setError(String message) {
    debugPrint("[VIDEO ERROR] $message");
    setState(() {
      _status = message;
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
      body: ctrl == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 12),
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
            )
          : SizedBox.expand(
              child: VlcPlayer(
                controller: ctrl,
                aspectRatio: 16 / 9,
                placeholder: const Center(child: CircularProgressIndicator()),
              ),
            ),
    );
  }
}
