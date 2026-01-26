import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/configs/assets/app_images.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';

class VideoCard extends StatefulWidget {
  final int rowId;
  final int columnId;
  final String imageUrl;
  final String title;
  final String description;
  final String duration;
  final VoidCallback? onTap;

  const VideoCard({
    super.key,
    required this.rowId,
    required this.columnId,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.duration,
    this.onTap,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
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
              scale: isFocused ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: isFocused ? 10 : 0),
                width: 300.widthMultiplier,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.radiusMultipier),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isFocused ? 0.3 : 0.1),
                      blurRadius: isFocused ? 20 : 8,
                      offset: Offset(0, isFocused ? 8 : 4),
                      spreadRadius: isFocused ? 2 : 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.radiusMultipier),
                      child: Image.asset(
                        widget.imageUrl,
                        width: double.infinity,
                        height: 200.heightMultiplier,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isFocused
                              ? 55.widthMultiplier
                              : 40.widthMultiplier,
                          height: isFocused
                              ? 55.heightMultiplier
                              : 40.heightMultiplier,
                          child: SvgPicture.asset(AppImages.play),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 32.heightMultiplier,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.widthMultiplier,
                          vertical: 3.heightMultiplier,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.9),
                        ),
                        child: Text(
                          widget.duration,
                          style: context.medium.copyWith(
                            fontSize: 10.textMultiplier,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isFocused
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.9),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12.radiusMultipier),
                            bottomRight: Radius.circular(12.radiusMultipier),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.widthMultiplier,
                          vertical: 5.heightMultiplier,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              style: context.semiBold.copyWith(
                                fontSize: 12.textMultiplier,
                                color: AppColors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.description,
                              style: context.regular.copyWith(
                                fontSize: 9.textMultiplier,
                                color: AppColors.white.withOpacity(0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
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
