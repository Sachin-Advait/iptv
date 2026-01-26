import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';

class CarouselBanner extends StatefulWidget {
  final List<String> banners;
  final VoidCallback? onPlayPressed;
  final double height;
  final Duration autoPlayInterval;
  final Duration autoPlayAnimationDuration;
  final Curve autoPlayCurve;

  const CarouselBanner({
    super.key,
    required this.banners,
    this.onPlayPressed,
    this.height = 300,
    this.autoPlayInterval = const Duration(seconds: 5),
    this.autoPlayAnimationDuration = const Duration(milliseconds: 800),
    this.autoPlayCurve = Curves.fastOutSlowIn,
  });

  @override
  State<CarouselBanner> createState() => _CarouselBannerState();
}

class _CarouselBannerState extends State<CarouselBanner> {
  int _currentBannerIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final RecentFocusNode _playFocusNode =
      RecentFocusNode(group: FocusGroup.button)
        ..row = -1
        ..column = 0;

  @override
  Widget build(BuildContext context) {
    debugPrint('PLAY BUTTON BUILD -> node=${_playFocusNode.hashCode}');
    return Stack(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: widget.height.heightMultiplier,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: widget.autoPlayInterval,
            autoPlayAnimationDuration: widget.autoPlayAnimationDuration,
            autoPlayCurve: widget.autoPlayCurve,
            onPageChanged: (index, reason) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
          ),
          items: widget.banners.map((banner) {
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(banner),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 0.7, 0.85, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.10),
                        AppColors.bg.withValues(alpha: 0.60),
                        AppColors.bg,
                      ],
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),

        // Dots Indicator
        Positioned(
          bottom: 16,
          right: 16,
          child: Row(
            children: widget.banners.asMap().entries.map((entry) {
              return Container(
                width: 10.widthMultiplier,
                height: 10.heightMultiplier,
                margin: EdgeInsets.symmetric(horizontal: 4.widthMultiplier),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary),
                  color: _currentBannerIndex == entry.key
                      ? AppColors.primary
                      : Colors.transparent,
                ),
              );
            }).toList(),
          ),
        ),

        // Play Button
        if (widget.onPlayPressed != null)
          Positioned(
            bottom: 16,
            left: 16,
            child: Focus(
              focusNode: _playFocusNode,
              onFocusChange: (v) {
                debugPrint('PLAY BUTTON FOCUS CHANGE = $v');
              },
              child: Builder(
                builder: (context) {
                  final isFocused = Focus.of(context).hasFocus;

                  return AnimatedScale(
                    scale: isFocused ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: isFocused ? AppColors.beige : Colors.white,
                        boxShadow: isFocused
                            ? [
                                BoxShadow(
                                  color: AppColors.beige.withValues(alpha: 0.6),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.black,
                          ),
                          6.horizontalSpace,
                          Text("Play", style: context.semiBold),
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
                  widget.onPlayPressed?.call();
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
            ),
          ),
      ],
    );
  }
}
