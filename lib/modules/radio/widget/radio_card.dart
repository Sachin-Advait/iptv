import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';

class RadioCard extends StatefulWidget {
  final int rowId;
  final int columnId;
  final RadioStation station;
  final bool isPlaying;
  final VoidCallback? onTap;

  const RadioCard({
    super.key,
    required this.rowId,
    required this.columnId,
    required this.station,
    this.isPlaying = false,
    this.onTap,
  });

  @override
  State<RadioCard> createState() => _RadioCardState();
}

class _RadioCardState extends State<RadioCard> {
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
        autofocus: widget.rowId == 1,
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;

            return Container(
              height: 80.heightMultiplier,
              padding: EdgeInsets.symmetric(horizontal: 24.widthMultiplier),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.radiusMultipier),
                border: Border.all(
                  color: isFocused ? AppColors.primary : Colors.transparent,
                  width: isFocused ? 2 : 0,
                ),
              ),
              child: Row(
                children: [
                  Image.asset(
                    widget.station.imagePath,
                    fit: BoxFit.contain,
                    width: 110,
                  ),
                  20.horizontalSpace,
                  Expanded(
                    child: Text(
                      widget.station.name,
                      style: context.semiBold.copyWith(
                        fontSize: 18.textMultiplier,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
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

class RadioStation {
  final String name;
  final String imagePath;
  final String frequency;

  RadioStation({
    required this.name,
    required this.imagePath,
    required this.frequency,
  });
}
