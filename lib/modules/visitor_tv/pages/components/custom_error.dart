import 'package:flutter/material.dart';
import 'package:oman_tv/common/constants/app_errors.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/modules/visitor_tv/cubit/visitor_tv_cubit.dart';
import 'package:oman_tv/modules/visitor_tv/pages/components/header.dart';

class CustomError extends StatelessWidget {
  const CustomError({
    super.key,
    required this.scaleFactor,
    required DateTime currentTime,
    required this.isRTL,
    required this.state,
  }) : _currentTime = currentTime;

  final double scaleFactor;
  final DateTime _currentTime;
  final bool isRTL;
  final TVDisplayError state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Header(
          scaleFactor: scaleFactor,
          currentTime: _currentTime,
          isRTL: isRTL,
        ),
        Expanded(
          child: Center(
            child: Container(
              padding: EdgeInsets.all(40 * scaleFactor),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    state.isNetworkError ? Icons.wifi_off : Icons.error,
                    size: 64 * scaleFactor,
                    color: Colors.red,
                  ),
                  SizedBox(height: 20 * scaleFactor),
                  Text(
                    state.isNetworkError
                        ? state.message
                        : AppErrors.serverError,
                    style: TextStyle(
                      fontSize: 24 * scaleFactor,
                      fontWeight: FontWeight.w700,
                      color: AppColors.red,
                    ),
                  ),
                  SizedBox(height: 5 * scaleFactor),
                  Text(
                    'The TV is trying to reconnect...',
                    style: TextStyle(
                      fontSize: 16 * scaleFactor,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 30 * scaleFactor),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    strokeWidth: 4 * scaleFactor,
                  ),
                  SizedBox(height: 30 * scaleFactor),
                  Text(
                    'This will reconnect automatically',
                    style: TextStyle(
                      fontSize: 16 * scaleFactor,
                      color: AppColors.brownDeep,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 70),
      ],
    );
  }
}
