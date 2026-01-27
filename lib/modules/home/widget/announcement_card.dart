import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';

class AnnouncementCard extends StatefulWidget {
  final int rowId;
  final int columnId;
  final String icon;
  final String label;
  final VoidCallback? onTap;

  const AnnouncementCard({
    super.key,
    required this.rowId,
    required this.columnId,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  State<AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<AnnouncementCard> {
  final RecentFocusNode _focusNode = RecentFocusNode(group: FocusGroup.listRow);

  @override
  Widget build(BuildContext context) {
    _focusNode.row = widget.rowId;
    _focusNode.column = widget.columnId;

    return GestureDetector(
      onTap: () {
        RecentFocusTraversalPolicy.setFocus(_focusNode, true);
        widget.onTap?.call();
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: false,
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;

            return AnimatedScale(
              scale: isFocused ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Container(
                width: 230.widthMultiplier,
                padding: EdgeInsets.symmetric(vertical: 16.heightMultiplier),
                margin: EdgeInsets.symmetric(
                  horizontal: isFocused
                      ? 12.widthMultiplier
                      : 8.widthMultiplier,
                ),
                decoration: BoxDecoration(
                  color: isFocused ? AppColors.beige : AppColors.lightBeige,
                  borderRadius: BorderRadius.circular(16.radiusMultipier),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: Offset(2, 2),
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedScale(
                      scale: isFocused ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: SvgPicture.asset(
                        widget.icon,
                        width: 50.widthMultiplier,
                        height: 50.heightMultiplier,
                        colorFilter: ColorFilter.mode(
                          AppColors.primary.withValues(alpha: .6),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: context.semiBold.copyWith(
                        fontSize: 16.textMultiplier,
                        color: AppColors.brownDeep,
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
            widget.onTap?.call();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
      ),
    );
  }
}
