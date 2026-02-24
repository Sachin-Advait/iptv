import 'package:flutter/material.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';

class NoInternetBanner extends StatelessWidget {
  const NoInternetBanner({super.key, required this.top});

  final double top;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: 20,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.amberOrange.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'No Internet Connection',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
