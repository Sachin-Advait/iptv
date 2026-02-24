import 'package:flutter/material.dart';
import 'package:oman_tv/configs/lang/localization_cubit.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/models/display_token.dart';

class NowServing extends StatelessWidget {
  const NowServing({
    super.key,
    required this.nowServing,
    required this.scaleFactor,
  });

  final List<DisplayToken> nowServing;
  final double scaleFactor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200 * scaleFactor,
      decoration: BoxDecoration(
        color: AppColors.warmGray,
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
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(15 * scaleFactor),
            ),
            child: Text(
              context.tr('now_serving'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ),

          SizedBox(height: 8 * scaleFactor),

          Expanded(
            child: nowServing.isEmpty
                ? Center(
                    child: Text(
                      context.tr('no_tokens_serving'),
                      style: TextStyle(fontSize: 20, color: AppColors.white),
                    ),
                  )
                : ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    itemCount: nowServing.length,
                    itemBuilder: (context, index) {
                      final token = nowServing[index];

                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 1,
                              horizontal: 20,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  token.token,
                                  style: TextStyle(
                                    color: AppColors.brownVeryDark,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  token.counter,
                                  style: TextStyle(
                                    color: AppColors.brownVeryDark,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (index != nowServing.length - 1)
                            Divider(
                              color: AppColors.brownVeryDark.withValues(
                                alpha: 0.6,
                              ),
                              height: 3,
                              thickness: 0.5,
                              indent: 8,
                              endIndent: 8,
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
