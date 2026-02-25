import 'package:flutter/material.dart';
import 'package:oman_tv/configs/lang/localization_cubit.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';

class HoldTokens extends StatelessWidget {
  const HoldTokens({
    super.key,
    required this.upcomingTokens,
    required this.scaleFactor,
    this.height,
  });

  final List<String> upcomingTokens;
  final double scaleFactor;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 200 * scaleFactor,
      decoration: BoxDecoration(
        color: AppColors.brownVeryDark,
        borderRadius: BorderRadius.circular(15 * scaleFactor),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8 * scaleFactor,
              vertical: 6 * scaleFactor,
            ),
            alignment: Alignment.center,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.almostBlack,
              borderRadius: BorderRadius.circular(15 * scaleFactor),
            ),
            child: Text(
              context.tr('hold_tokens'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 8 * scaleFactor),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(
                height: 3,
                thickness: 0.5,
                endIndent: 10,
                indent: 10,
                color: AppColors.beige.withValues(alpha: 0.6),
              ),
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 10),
              shrinkWrap: true,
              itemCount: upcomingTokens.length,
              itemBuilder: (context, index) {
                final token = upcomingTokens[index];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 1),
                      child: Text(
                        token,
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
