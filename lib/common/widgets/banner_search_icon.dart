// common/widgets/carousel_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';

class BannerSearchIcon extends StatelessWidget {
  final RecentFocusNode focusNode;
  final VoidCallback onToggle;

  const BannerSearchIcon({
    super.key,
    required this.focusNode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      onFocusChange: (v) {
        debugPrint('SEARCH BUTTON FOCUS CHANGE = $v');
      },
      onKeyEvent: (_, event) {
        if (event is KeyUpEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.select)) {
          onToggle();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Builder(
        builder: (context) {
          final isFocused = Focus.of(context).hasFocus;

          return AnimatedScale(
            scale: isFocused ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: GestureDetector(
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFocused
                      ? AppColors.beige
                      : Colors.white.withValues(alpha: 0.9),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: AppColors.beige.withValues(alpha: 0.6),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Icon(
                  Icons.search,
                  color: isFocused ? AppColors.white : AppColors.black,
                  size: 24,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
