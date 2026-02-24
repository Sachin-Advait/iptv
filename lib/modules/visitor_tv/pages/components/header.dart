import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:oman_tv/configs/assets/app_images.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/modules/visitor_tv/pages/components/helper.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.scaleFactor,
    required DateTime currentTime,
    required this.isRTL,
  }) : _currentTime = currentTime;

  final double scaleFactor;
  final DateTime _currentTime;
  final bool isRTL;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scaleFactor,
        vertical: 8 * scaleFactor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(AppImages.visitorLogo, height: 45 * scaleFactor),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                intl.DateFormat('HH:mm').format(_currentTime),
                style: TextStyle(
                  color: AppColors.brownDeep,
                  fontSize: 20 * scaleFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                Helper.getFormattedDate(_currentTime, isRTL),
                style: TextStyle(
                  color: AppColors.brownDeep,
                  fontSize: 12 * scaleFactor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
