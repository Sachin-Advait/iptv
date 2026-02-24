// modules/order/pages/widgets/order_error_view.dart
import 'package:flutter/material.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';

class OrderErrorView extends StatelessWidget {
  const OrderErrorView({
    super.key,
    required this.message,
    required this.isNetworkError,
    required this.onRetry,
    required this.color,
  });

  final String message;
  final bool isNetworkError;
  final VoidCallback onRetry;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isNetworkError ? Icons.wifi_off : Icons.error_outline,
              size: 64,
              color: AppColors.red,
            ),
            const SizedBox(height: 20),
            Text(
              isNetworkError ? message : 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Trying to reconnect automatically...',
              style: TextStyle(fontSize: 15, color: color),
            ),
            const SizedBox(height: 28),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: 4,
            ),
            const SizedBox(height: 28),
            Text(
              'This will reconnect automatically',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: AppColors.amberOrange,
              ),
            ),
            const SizedBox(height: 32),
            // Manual retry for when the kiosk operator wants to force it
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh, size: 20, color: AppColors.white),
              label: Text(
                'Retry',
                style: TextStyle(color: AppColors.white, fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
