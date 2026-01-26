import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';

class GroupCard extends StatefulWidget {
  final int rowId;
  final int columnId;
  final RadioItem item;
  final VoidCallback? onTap;

  const GroupCard({
    super.key,
    required this.rowId,
    required this.columnId,
    required this.item,
    this.onTap,
  });

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
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

            return Container(
              width: 230.widthMultiplier,
              height: 82.heightMultiplier,
              padding: EdgeInsets.all(20.widthMultiplier),
              decoration: BoxDecoration(
                color: isFocused ? AppColors.beige : AppColors.lightBeige,
                borderRadius: BorderRadius.circular(16.radiusMultipier),
                border: isFocused
                    ? Border.all(color: AppColors.primary, width: 3)
                    : null,
              ),
              child: Center(
                child: widget.item.imageType == RadioImageType.asset
                    ? Image.asset(
                        widget.item.imagePath,
                        width: widget.item.imageWidth ?? 120.widthMultiplier,
                        height: widget.item.imageHeight ?? 80.heightMultiplier,
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        widget.item.imagePath,
                        width: widget.item.imageWidth ?? 120.widthMultiplier,
                        height: widget.item.imageHeight ?? 80.heightMultiplier,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 40.widthMultiplier,
                                color: Colors.grey[400],
                              ),
                            ),
                          );
                        },
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

class RadioItem {
  final String imagePath;
  final Color? backgroundColor;
  final double? imageWidth;
  final double? imageHeight;
  final VoidCallback? onTap;
  final RadioImageType imageType;
  final String? label;

  RadioItem({
    required this.imagePath,
    this.backgroundColor,
    this.imageWidth,
    this.imageHeight,
    this.onTap,
    this.imageType = RadioImageType.asset,
    this.label,
  });
}

enum RadioImageType { asset, network }
