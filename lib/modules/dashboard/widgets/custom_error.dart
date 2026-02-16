import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';

class CustomError extends StatefulWidget {
  const CustomError({
    super.key,
    required this.message,
    this.isNetworkError = true,
    this.onRetry,
  });

  final String message;
  final bool isNetworkError;
  final VoidCallback? onRetry;

  @override
  State<CustomError> createState() => _CustomErrorState();
}

class _CustomErrorState extends State<CustomError> {
  late final RecentFocusNode _retryButtonFocus;

  @override
  void initState() {
    super.initState();

    debugPrint('🔴 ERROR SCREEN - Creating new root');

    // Retry button - row 0, column 0
    _retryButtonFocus = RecentFocusNode(group: FocusGroup.button)
      ..row = 0
      ..column = 0;

    // Auto-focus the retry button when error appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        RecentFocusTraversalPolicy.setFocus(_retryButtonFocus, true);
      }
    });
  }

  @override
  void dispose() {
    debugPrint('🔴 ERROR SCREEN - Disposing root and button');
    _retryButtonFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.isNetworkError ? Icons.wifi_off : Icons.error,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.red,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'The TV is trying to reconnect...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.primary),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 4,
            ),
            const SizedBox(height: 30),
            const Text(
              'This will reconnect automatically',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.brownDeep,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.onRetry != null) ...[
              const SizedBox(height: 30),
              FocusTraversalGroup(
                policy: const RecentFocusTraversalPolicy(
                  group: FocusGroup.button,
                ),
                child: Focus(
                  focusNode: _retryButtonFocus,
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.select ||
                          event.logicalKey == LogicalKeyboardKey.enter) {
                        widget.onRetry?.call();
                        return KeyEventResult.handled;
                      }
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
                          onTap: widget.onRetry,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: isFocused
                                  ? AppColors.primary
                                  : Colors.white,
                              boxShadow: isFocused
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.6,
                                        ),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  color: isFocused
                                      ? AppColors.white
                                      : AppColors.black,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Retry Now",
                                  style: context.semiBold.copyWith(
                                    color: isFocused
                                        ? AppColors.white
                                        : AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
