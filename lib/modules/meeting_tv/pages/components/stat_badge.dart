import 'package:flutter/material.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';

class StatBadge extends StatelessWidget {
  const StatBadge({
    super.key,
    required this.icon,
    required this.count,
    required this.color,
    required this.label,
  });

  final String icon;
  final String count;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(icon, color: AppColors.white, height: 30),
          const SizedBox(width: 15),
          Text(
            count,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 23,
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
