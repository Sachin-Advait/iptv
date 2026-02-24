import 'dart:async';

import 'package:flutter/material.dart';

class AnimatedFloorPlan extends StatefulWidget {
  final String imagePath;
  final double height;

  const AnimatedFloorPlan({
    super.key,
    required this.imagePath,
    this.height = 500,
  });

  @override
  State<AnimatedFloorPlan> createState() => _AnimatedFloorPlanState();
}

class _AnimatedFloorPlanState extends State<AnimatedFloorPlan>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Alignment> _alignmentAnimation;
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 12), // Total cycle duration
      vsync: this,
    );

    // Scale animation with stages:
    // 0.0 - 0.25: Zoom in from 1.0 to 3.0 (bottom left)
    // 0.25 - 0.5: Stay zoomed at 3.0 (moving to bottom right)
    // 0.5 - 0.75: Zoom out from 3.0 to 1.0
    // 0.75 - 1.0: Stay at 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 3.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(3.0), weight: 25),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 3.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 25),
    ]).animate(_controller);

    // Alignment animation with stages:
    // 0.0 - 0.25: Stay at bottom left
    // 0.25 - 0.5: Move from bottom left to bottom right (while zoomed)
    // 0.5 - 1.0: Move back to center as we zoom out
    _alignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: ConstantTween<Alignment>(const Alignment(-0.5, 0.6)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(
          begin: const Alignment(-0.5, 0.6),
          end: const Alignment(0.1, 1),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(
          begin: const Alignment(0.1, 1),
          end: Alignment.center,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Alignment>(Alignment.center),
        weight: 25,
      ),
    ]).animate(_controller);

    // Start the animation cycle
    _startAnimationCycle();
  }

  void _startAnimationCycle() {
    // Add a 2-second pause between cycles
    _animationTimer = Timer.periodic(const Duration(seconds: 12), (timer) {
      if (mounted) {
        _controller.forward(from: 0.0);
      }
    });

    // Start first animation immediately
    _controller.forward();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                alignment: _alignmentAnimation.value,
                child: Image.asset(
                  widget.imagePath,
                  height: widget.height,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
