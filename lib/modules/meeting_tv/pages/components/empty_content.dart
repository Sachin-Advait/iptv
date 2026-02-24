import 'package:flutter/material.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';

class EmptyContent extends StatelessWidget {
  const EmptyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with loading indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Image.asset("assets/images/logo.png", height: 40),
              const SizedBox(width: 16),
              const Text(
                'SpaceHub',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
              const Spacer(),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Loading...',
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/logo.png", height: 40),
                const SizedBox(height: 20),
                Text(
                  'Initializing Display...',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.5),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
