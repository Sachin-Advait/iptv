import 'package:flutter/material.dart';
import 'package:oman_tv/configs/lang/localization_cubit.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/models/display_token.dart';

class NowCalling extends StatefulWidget {
  const NowCalling({super.key, required this.calls, required this.scaleFactor});

  final List<DisplayToken> calls;
  final double scaleFactor;

  @override
  State<NowCalling> createState() => _NowCallingState();
}

class _NowCallingState extends State<NowCalling> {
  bool _shouldBlink = false;

  @override
  void initState() {
    super.initState();
    // Start blinking after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _shouldBlink = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.calls.take(2).map((call) {
        return _shouldBlink
            ? _BlinkingCard(call: call, scaleFactor: widget.scaleFactor)
            : _buildNowCallingCard(context, call, widget.scaleFactor);
      }).toList(),
    );
  }
}

class _BlinkingCard extends StatefulWidget {
  const _BlinkingCard({required this.call, required this.scaleFactor});

  final DisplayToken call;
  final double scaleFactor;

  @override
  State<_BlinkingCard> createState() => _BlinkingCardState();
}

class _BlinkingCardState extends State<_BlinkingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.2, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: _buildNowCallingCard(context, widget.call, widget.scaleFactor),
        );
      },
    );
  }
}

Widget _buildNowCallingCard(
  BuildContext context,
  DisplayToken call,
  double scaleFactor,
) {
  return Container(
    margin: EdgeInsets.only(bottom: 12 * scaleFactor),
    height: 140 * scaleFactor,
    decoration: BoxDecoration(
      color: AppColors.red,
      borderRadius: BorderRadius.circular(12 * scaleFactor),
      border: Border.all(color: AppColors.red, width: 1 * scaleFactor),
    ),
    child: Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.symmetric(vertical: 10 * scaleFactor),
          child: Text(
            context.tr('now_calling'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Content
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12 * scaleFactor),
                bottomRight: Radius.circular(12 * scaleFactor),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    call.token,
                    style: TextStyle(
                      color: AppColors.red,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4 * scaleFactor),
                  Text(
                    call.counter,
                    style: TextStyle(
                      color: AppColors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
