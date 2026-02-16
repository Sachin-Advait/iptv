import 'package:flutter/material.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/widgets/carousel_banner.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';

class BannerPlaceHolder extends StatelessWidget {
  const BannerPlaceHolder({super.key, required this.widget, this.errorMessage});

  final String? errorMessage;
  final CarouselBanner widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.heightMultiplier,
      width: double.infinity,
      color: AppColors.beige,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, color: AppColors.white, size: 50.textMultiplier),
            8.verticalSpace,
            Text(
              errorMessage ?? 'No banners available for ${widget.category}',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16.textMultiplier,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
