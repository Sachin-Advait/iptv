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

  // 🔥 New
  final bool isHeaderStyle;
  final bool isSelected;

  const CategoryCard({
    super.key,
    required this.rowId,
    required this.columnId,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isHeaderStyle = false,
    this.isSelected = false,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  late RecentFocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = RecentFocusNode(
      group: widget.isHeaderStyle ? FocusGroup.header : FocusGroup.listRow,
    );
  }

  @override
  void didUpdateWidget(covariant CategoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔁 Update focus group dynamically when mode changes
    if (oldWidget.isHeaderStyle != widget.isHeaderStyle) {
      _focusNode.group = widget.isHeaderStyle
          ? FocusGroup.liveHeader
          : FocusGroup.listRow;
    }
  }

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
        autofocus: widget.isHeaderStyle && widget.columnId == 0,
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;
            final bool showHeaderSelected =
                widget.isHeaderStyle && widget.isSelected && !isFocused;

            return AnimatedScale(
              scale: isFocused ? 1.3 : 1.0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isFocused
                      ? 25.widthMultiplier
                      : 8.widthMultiplier,
                ),
                alignment: Alignment.center,
                width: widget.isHeaderStyle
                    ? 180.widthMultiplier
                    : 230.widthMultiplier,
                padding: EdgeInsets.symmetric(
                  vertical: widget.isHeaderStyle
                      ? 10.heightMultiplier
                      : 16.heightMultiplier,
                  horizontal: widget.isHeaderStyle ? 20.heightMultiplier : 0,
                ),
                decoration: BoxDecoration(
                  // 🎯 HEADER MODE STYLE
                  gradient: widget.isHeaderStyle
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isFocused || showHeaderSelected
                              ? [AppColors.bg, AppColors.beige]
                              : [Colors.transparent, Colors.transparent],
                        )
                      : null,

                  color: isFocused ? AppColors.primary : AppColors.beige,
                  borderRadius: BorderRadius.circular(
                    widget.isHeaderStyle
                        ? 10.radiusMultipier
                        : 16.radiusMultipier,
                  ),
                  boxShadow: widget.isHeaderStyle
                      ? (isFocused
                            ? [
                                BoxShadow(
                                  color: AppColors.primary,
                                  offset: const Offset(0, 3),
                                  blurRadius: 0,
                                ),
                              ]
                            : null)
                      : (isFocused
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                  spreadRadius: 3,
                                ),
                              ]
                            : null),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!widget.isHeaderStyle) ...[
                      SvgPicture.asset(
                        widget.icon,
                        width: 40.widthMultiplier,
                        height: 40.heightMultiplier,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      20.horizontalSpace,
                    ],
                    Text(
                      widget.label,
                      style: context.semiBold.copyWith(
                        fontSize: widget.isHeaderStyle
                            ? 16.textMultiplier
                            : 20.textMultiplier,
                        color: widget.isHeaderStyle
                            ? (isFocused || showHeaderSelected
                                  ? AppColors.primary
                                  : AppColors.black)
                            : AppColors.white,
                        fontWeight: isFocused || showHeaderSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
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
