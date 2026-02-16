// common/widgets/carousel_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';

class ExpandedSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode textFieldFocusNode;
  final VoidCallback onClose;
  final VoidCallback onSubmit;

  const ExpandedSearchBar({
    super.key,
    required this.controller,
    required this.textFieldFocusNode,
    required this.onClose,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyUpEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          textFieldFocusNode.requestFocus();
          SystemChannels.textInput.invokeMethod('TextInput.show');
          return KeyEventResult.handled;
        }

        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.escape ||
                event.logicalKey == LogicalKeyboardKey.goBack)) {
          textFieldFocusNode.unfocus();
          onClose();
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () {
          textFieldFocusNode.requestFocus();
          SystemChannels.textInput.invokeMethod('TextInput.show');
        },
        onDoubleTap: onClose,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              alignment: Alignment.centerRight,
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Container(
            width: 400.widthMultiplier,
            height: 50.heightMultiplier,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.radiusMultipier),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                16.horizontalSpace,
                Icon(Icons.search, color: Colors.grey[600], size: 24),
                12.horizontalSpace,
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: textFieldFocusNode,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                    style: context.regular.copyWith(
                      fontSize: 16.textMultiplier,
                      color: AppColors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: context.regular.copyWith(
                        fontSize: 16.textMultiplier,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) {
                      onSubmit();
                      onClose();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
