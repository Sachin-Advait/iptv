// common/widgets/carousel_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';
import 'package:oman_tv/models/dashboard_model.dart';
import 'package:oman_tv/routes/app_pages.dart';

class VideoPlayButton extends StatelessWidget {
  const VideoPlayButton({
    super.key,
    required RecentFocusNode playFocusNode,
    required this.video,
  }) : _playFocusNode = playFocusNode;

  final RecentFocusNode _playFocusNode;
  final BannerZoneElement? video;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      child: Focus(
        focusNode: _playFocusNode,
        onFocusChange: (v) {
          debugPrint('PLAY BUTTON FOCUS CHANGE = $v');
        },
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.video,
              arguments: {'videoUrl': video},
            );
          },
          child: Builder(
            builder: (context) {
              final isFocused = Focus.of(context).hasFocus;

              return AnimatedScale(
                scale: isFocused ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: isFocused ? AppColors.beige : Colors.white,
                    boxShadow: isFocused
                        ? [
                            BoxShadow(
                              color: AppColors.beige.withValues(alpha: 0.6),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.black,
                      ),
                      6.horizontalSpace,
                      Text("Play", style: context.semiBold),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        onKeyEvent: (_, event) {
          if (event is KeyUpEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.select)) {
            Navigator.pushNamed(
              context,
              Routes.video,
              arguments: {'videoUrl': video},
            );
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
      ),
    );
  }
}
