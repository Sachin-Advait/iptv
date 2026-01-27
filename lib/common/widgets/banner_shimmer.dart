// common/widgets/banner_shimmer.dart
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

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
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
          child: Container(
            height: widget.height.heightMultiplier,
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.beige),
          ),
        );
      },
    );
  }
}
