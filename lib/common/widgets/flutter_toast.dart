import 'package:flutter/material.dart';
import 'package:oman_tv/common/utils/global_keys.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

void flutterToast({required String message, Color? color}) {
  final overlayState = GlobalKeys.navigatorKey.currentState?.overlay;

  if (overlayState == null) {
    debugPrint("❌ Overlay not ready");
    return;
  }

  showTopSnackBar(
    overlayState,
    animationDuration: Duration(seconds: 1),
    CustomSnackBar.info(
      backgroundColor: color ?? AppColors.primary,
      message: message,
      iconPositionLeft: 30,
      iconRotationAngle: 0,
      messagePadding: EdgeInsetsGeometry.all(0),
      icon: const Padding(
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.error_outline, color: Colors.white, size: 28),
      ),
      textStyle: TextStyle(fontSize: 14, color: Colors.white),
    ),
  );
}
