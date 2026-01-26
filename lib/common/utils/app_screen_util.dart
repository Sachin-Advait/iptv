import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppScreenUtil {
  static late double screenWidth;
  static late double screenHeight;
  static late double textMultiplier;
  static late double imageSizeMultiplier;
  static late double heightMultiplier;
  static late double widthMultiplier;
  static late double radiusMultiplier;
  static bool isPortrait = true;
  static bool isMobilePortrait = false;
  void init(BoxConstraints constraints) {
    textMultiplier = 1.sp;
    imageSizeMultiplier = 1;
    heightMultiplier = 1.h;
    widthMultiplier = 1.w;
    radiusMultiplier = 1.r;
  }
}

extension SizeExtension on num {
  double get widthMultiplier => this * AppScreenUtil.widthMultiplier;
  double get heightMultiplier => this * AppScreenUtil.heightMultiplier;
  double get imageSizeMultiplier => this * AppScreenUtil.imageSizeMultiplier;
  double get textMultiplier => this * AppScreenUtil.textMultiplier;
  double get radiusMultipier => this * AppScreenUtil.radiusMultiplier;
  SizedBox get verticalSpace =>
      SizedBox(height: this * AppScreenUtil.heightMultiplier);
  SizedBox get horizontalSpace =>
      SizedBox(width: this * AppScreenUtil.widthMultiplier);
}
