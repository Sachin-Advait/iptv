import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';

class CustomTab extends StatefulWidget {
  final int id;
  final String label;
  final bool isSelected;

  const CustomTab({
    super.key,
    required this.id,
    required this.label,
    required this.isSelected,
  });

  @override
  State<CustomTab> createState() => _CustomTabState();
}

class _CustomTabState extends State<CustomTab> {
  final RecentFocusNode _focusNode = RecentFocusNode(group: FocusGroup.header);
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    _focusNode.row = 0;
    _focusNode.column = widget.id;

    final bool isFocused = _isFocused;

    final bool isSelected = widget.isSelected;
    final bool showSelected = isSelected && !isFocused;

    return GestureDetector(
      onTap: () {
        RecentFocusTraversalPolicy.setFocus(_focusNode, true);
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.id == 0, // ✅ only first tab
        onFocusChange: (value) {
          setState(() {
            _isFocused = value;
          });
        },
        child: Container(
          height: 50,
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.symmetric(horizontal: 6.widthMultiplier),
          padding: EdgeInsets.symmetric(
            horizontal: 20.widthMultiplier,
            vertical: 10.heightMultiplier,
          ),
          decoration: BoxDecoration(
            gradient: isFocused || showSelected
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.bg, AppColors.beige],
                  )
                : null,
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary,
                      offset: const Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: context.medium.copyWith(
              fontWeight: isFocused ? FontWeight.w600 : FontWeight.w500,
              color: isFocused ? AppColors.primary : AppColors.black,
              fontSize: isFocused ? 16.textMultiplier : 14.textMultiplier,
            ),
          ),
        ),
        onKeyEvent: (_, event) {
          if (event is KeyUpEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.select)) {
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
      ),
    );
  }
}
