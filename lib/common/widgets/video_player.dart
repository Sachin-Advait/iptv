import 'package:flutter/material.dart';
import 'package:flutter_multicast_lock/flutter_multicast_lock.dart';
import 'package:flutter_vlc_player_16kb/flutter_vlc_player.dart';

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

    // Acquire multicast lock only for multicast/udp streams (Wi-Fi use case)
    if (_isUdp(url)) {
      try {
        await _multicastLock.acquireMulticastLock();
        _multicastLockHeld = true;
      } catch (e) {
        // If lock fails, playback may still work on Ethernet, but can fail on Wi-Fi.

        _status = "Warning: multicast lock not acquired: $e";
        if (mounted) setState(() {});
        throw Exception('2. App crashed due to $e');
      }
    }

    // Lower network caching for lower latency (tune per network quality)
    // final options = VlcPlayerOptions();
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

    setState(() {
      _controller = ctrl;
      _status = "Playing";
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
      body: ctrl == null
          ? Center(child: Text(_status))
          : AspectRatio(
              aspectRatio: 16 / 9,
              child: VlcPlayer(
                aspectRatio: 16 / 9,
                controller: ctrl,
                placeholder: const Center(child: CircularProgressIndicator()),
              ),
            ),
    );
  }
}
