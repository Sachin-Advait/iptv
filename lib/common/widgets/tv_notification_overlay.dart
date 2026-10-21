import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:oman_tv/services/tv_notification_controller.dart';

/// Shows pushed notifications full screen above the whole app: zooms in with
/// a chime, stays for the notification's duration, then zooms out.
class TvNotificationOverlay extends StatefulWidget {
  final Widget child;

  const TvNotificationOverlay({super.key, required this.child});

  @override
  State<TvNotificationOverlay> createState() => _TvNotificationOverlayState();
}

class _TvNotificationOverlayState extends State<TvNotificationOverlay>
    with TickerProviderStateMixin {
  final _controller = TvNotificationController.instance;
  final AudioPlayer _player = AudioPlayer();

  late final AnimationController _zoom = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
    reverseDuration: const Duration(milliseconds: 500),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final AnimationController _countdown = AnimationController(vsync: this);

  TvNotification? _showing;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _controller.current.addListener(_onChanged);
  }

  Future<void> _onChanged() async {
    final next = _controller.current.value;
    _hideTimer?.cancel();

    if (next == null) {
      await _hide();
      return;
    }

    // Replace a notification already on screen
    if (_showing != null) {
      await _zoom.reverse();
    }
    if (!mounted) return;

    setState(() => _showing = next);
    _pulse.repeat(reverse: true);
    _countdown
      ..duration = Duration(seconds: next.durationSeconds)
      ..forward(from: 0);
    _zoom.forward(from: 0);

    if (next.playSound) _playChime();

    _hideTimer = Timer(Duration(seconds: next.durationSeconds), () {
      if (_controller.current.value?.id == next.id) _controller.dismiss();
    });
  }

  Future<void> _playChime() async {
    try {
      // "Ting-ting": the chime twice
      for (var i = 0; i < 2; i++) {
        await _player.play(AssetSource('audio/glass-sms.mp3'));
        await _player.onPlayerComplete.first.timeout(
          const Duration(seconds: 3),
        );
        if (_showing == null) return;
      }
    } catch (e) {
      debugPrint('[TV-NOTIFY] ❌ Chime failed: $e');
    }
  }

  Future<void> _hide() async {
    if (_showing == null) return;
    // Silence the chime without waiting on the platform player
    unawaited(
      _player.stop().catchError(
        (e) => debugPrint('[TV-NOTIFY] ⚠️ Could not stop chime: $e'),
      ),
    );
    await _zoom.reverse();
    _pulse.stop();
    _countdown.stop();
    if (mounted) setState(() => _showing = null);
  }

  @override
  void dispose() {
    _controller.current.removeListener(_onChanged);
    _hideTimer?.cancel();
    _zoom.dispose();
    _pulse.dispose();
    _countdown.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showing != null)
          Positioned.fill(
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _zoom, curve: Curves.easeOut),
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _zoom,
                  curve: Curves.easeOutBack,
                  reverseCurve: Curves.easeInCubic,
                ),
                child: _NotificationCard(
                  notification: _showing!,
                  pulse: _pulse,
                  countdown: _countdown,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoryStyle {
  final String label;
  final Color color;
  final IconData icon;

  const _CategoryStyle(this.label, this.color, this.icon);

  static _CategoryStyle of(String category) {
    switch (category) {
      case 'EMERGENCY':
        return const _CategoryStyle(
          'Emergency',
          Color(0xFFDC2626),
          Icons.emergency_share_rounded,
        );
      case 'WARNING':
        return const _CategoryStyle(
          'Warning',
          Color(0xFFF59E0B),
          Icons.warning_amber_rounded,
        );
      case 'ANNOUNCEMENT':
        return const _CategoryStyle(
          'Announcement',
          Color(0xFFA89168),
          Icons.campaign_rounded,
        );
      case 'CELEBRATION':
        return const _CategoryStyle(
          'Celebration',
          Color(0xFF10B981),
          Icons.celebration_rounded,
        );
      default:
        return const _CategoryStyle(
          'Information',
          Color(0xFF3B82F6),
          Icons.info_outline_rounded,
        );
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final TvNotification notification;
  final Animation<double> pulse;
  final Animation<double> countdown;

  const _NotificationCard({
    required this.notification,
    required this.pulse,
    required this.countdown,
  });

  @override
  Widget build(BuildContext context) {
    final style = _CategoryStyle.of(notification.category);
    final size = MediaQuery.of(context).size;
    final scale = size.shortestSide / 540;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 1.1,
            colors: [
              Color.lerp(style.color, Colors.black, 0.05)!,
              Color.lerp(style.color, Colors.black, 0.55)!,
            ],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 60 * scale),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: Tween(begin: 1.0, end: 1.15).animate(
                        CurvedAnimation(parent: pulse, curve: Curves.easeInOut),
                      ),
                      child: Container(
                        width: 110 * scale,
                        height: 110 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 3 * scale,
                          ),
                        ),
                        child: Icon(
                          style.icon,
                          color: Colors.white,
                          size: 60 * scale,
                        ),
                      ),
                    ),
                    SizedBox(height: 24 * scale),
                    Text(
                      style.label.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 6 * scale,
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                    Text(
                      notification.title,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 46 * scale,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    if ((notification.message ?? '').isNotEmpty) ...[
                      SizedBox(height: 16 * scale),
                      Text(
                        notification.message!,
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 24 * scale,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Time left before it zooms away
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedBuilder(
                animation: countdown,
                builder: (context, _) => LinearProgressIndicator(
                  value: 1 - countdown.value,
                  minHeight: 6 * scale,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
