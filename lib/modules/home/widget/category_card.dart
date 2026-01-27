import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';

class CategoryCard extends StatefulWidget {
  final int rowId;
  final int columnId;
  final String icon;
  final String label;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.rowId,
    required this.columnId,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  final RecentFocusNode _focusNode = RecentFocusNode(group: FocusGroup.listRow);

  @override
  Widget build(BuildContext context) {
    _focusNode.row = widget.rowId;
    _focusNode.column = widget.columnId;

    return GestureDetector(
      onTap: () {
        RecentFocusTraversalPolicy.setFocus(_focusNode, true);
        widget.onTap();
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.rowId == 0 && widget.columnId == 0,
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;

            return AnimatedScale(
              scale: isFocused ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isFocused
                      ? 12.widthMultiplier
                      : 8.widthMultiplier,
                ),
                alignment: Alignment.center,
                width: 230.widthMultiplier,
                padding: EdgeInsets.symmetric(vertical: 16.heightMultiplier),
                decoration: BoxDecoration(
                  color: isFocused ? AppColors.primary : AppColors.beige,
                  borderRadius: BorderRadius.circular(16.radiusMultipier),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: Offset(2, 2),
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: isFocused ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: SvgPicture.asset(
                        widget.icon,
                        width: 40.widthMultiplier,
                        height: 40.heightMultiplier,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    25.horizontalSpace,
                    Text(
                      widget.label,
                      style: context.semiBold.copyWith(
                        fontSize: 20.textMultiplier,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        onKeyEvent: (_, event) {
          if (event is KeyUpEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.select)) {
            widget.onTap();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
      ),
    );
  }
}
