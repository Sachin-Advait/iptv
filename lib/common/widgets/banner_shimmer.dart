import 'package:flutter/material.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';

class BannerShimmer extends StatefulWidget {
  final double height;
  const BannerShimmer({super.key, this.height = 300});

  @override
  State<BannerShimmer> createState() => _BannerShimmerState();
}

class _BannerShimmerState extends State<BannerShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height.heightMultiplier,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.lightBeige,
        borderRadius: BorderRadius.circular(16.radiusMultipier),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            children: [
              // Base shimmer layer
              Container(
                decoration: BoxDecoration(
                  color: AppColors.beige.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16.radiusMultipier),
                ),
              ),
              // Animated shimmer gradient
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(
                    _animation.value * MediaQuery.of(context).size.width -
                        MediaQuery.of(context).size.width,
                    0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          AppColors.white.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              // Skeleton content placeholders
              Padding(
                padding: EdgeInsets.all(24.widthMultiplier),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Title placeholder
                    Container(
                      height: 24.heightMultiplier,
                      width: 200.widthMultiplier,
                      decoration: BoxDecoration(
                        color: AppColors.beige.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.radiusMultipier),
                      ),
                    ),
                    12.verticalSpace,
                    // Subtitle placeholder
                    Container(
                      height: 16.heightMultiplier,
                      width: 150.widthMultiplier,
                      decoration: BoxDecoration(
                        color: AppColors.beige.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8.radiusMultipier),
                      ),
                    ),
                    20.verticalSpace,
                    // Button placeholder
                    Container(
                      height: 40.heightMultiplier,
                      width: 120.widthMultiplier,
                      decoration: BoxDecoration(
                        color: AppColors.beige.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.radiusMultipier),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AnimatedBannerWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const AnimatedBannerWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.delay = const Duration(milliseconds: 200),
  });

  @override
  State<AnimatedBannerWrapper> createState() => _AnimatedBannerWrapperState();
}

class _AnimatedBannerWrapperState extends State<AnimatedBannerWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
          ),
        );
      },
      child: widget.child,
    );
  }
}
