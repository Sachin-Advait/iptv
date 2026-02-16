// common/widgets/carousel_banner.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/common/widgets/banner_shimmer.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';
import 'package:oman_tv/models/dashboard_model.dart';
import 'package:oman_tv/modules/dashboard/cubit/dashboard_cubit.dart';
import 'package:oman_tv/routes/app_pages.dart';

class CarouselBanner extends StatefulWidget {
  final String category;
  final Function(String)? onSearch;

  const CarouselBanner({super.key, required this.category, this.onSearch});

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

  final RecentFocusNode _searchFocusNode =
      RecentFocusNode(group: FocusGroup.button)
        ..row = -1
        ..column = 1;

  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;

      if (!_isSearchExpanded) {
        _searchController.clear();
        _textFieldFocusNode.unfocus();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _textFieldFocusNode.requestFocus();
          SystemChannels.textInput.invokeMethod('TextInput.show');
        });
      }
    });
  }

  void _handleSearchSubmit() {
    if (_searchController.text.isNotEmpty) {
      widget.onSearch?.call(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        // Show shimmer while loading
        if (state.dashboardStatus == DashboardStatus.loading) {
          return const BannerShimmer(height: 300);
        }

        // Error state
        if (state.dashboardStatus == DashboardStatus.error) {
          return _buildPlaceholderBanner(errorMessage: state.errorMessage);
        }

        // Success state
        if (state.dashboardStatus == DashboardStatus.success) {
          // Check if layout has banner enabled
          if (state.dashboardData?.layout.bannerEnabled != true) {
            return const SizedBox.shrink(); // Hide banner if disabled
          }

          // Get banners for current category
          final categoryBanners =
              state.dashboardData?.bannerZone
                  .where((banner) => banner.category == widget.category)
                  .toList() ??
              [];

          // Get video URL for current category (for play button)
          final categoryVideo = state.dashboardData?.videoZone
              .where((video) => video.category == widget.category)
              .toList();

          final BannerZoneElement? video =
              (categoryVideo != null && categoryVideo.isNotEmpty)
              ? categoryVideo.first
              : null;

          // If no banners for this category, show placeholder
          if (categoryBanners.isEmpty) {
            return _buildPlaceholderBanner();
          }

          // Get all image URLs from category banners
          final allImageUrls = categoryBanners
              .expand((banner) => banner.imageUrls ?? [])
              .toList();

          if (allImageUrls.isEmpty) {
            return _buildPlaceholderBanner();
          }

          return AnimatedBannerWrapper(
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop && _isSearchExpanded) {
                  _toggleSearch();
                }
              },
              child: Stack(
                children: [
                  CarouselSlider(
                    carouselController: _carouselController,
                    options: CarouselOptions(
                      height: 300.heightMultiplier,
                      viewportFraction: 1.0,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      autoPlayAnimationDuration: const Duration(
                        milliseconds: 800,
                      ),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentBannerIndex = index;
                        });
                      },
                    ),
                    items: allImageUrls.map((imageUrl) {
                      return Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Gradient Overlay
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

                  // Dots Indicator (only if multiple banners)
                  if (allImageUrls.length > 1)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Row(
                        children: allImageUrls.asMap().entries.map((entry) {
                          return Container(
                            width: 10.widthMultiplier,
                            height: 10.heightMultiplier,
                            margin: EdgeInsets.symmetric(
                              horizontal: 4.widthMultiplier,
                            ),
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

                  // Netflix-style Search Bar (Top Right)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _isSearchExpanded
                        ? _buildExpandedSearchBar()
                        : _buildSearchIcon(),
                  ),

                  // Play Button (only if video exists for category)
                  if (video != null)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Focus(
                        focusNode: _playFocusNode,
                        onFocusChange: (v) {
                          debugPrint('PLAY BUTTON FOCUS CHANGE = $v');
                        },
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.video,
                              arguments: {'videoUrl': video},
                            );
                          },
                          child: Builder(
                            builder: (context) {
                              final isFocused = Focus.of(context).hasFocus;

                              return AnimatedScale(
                                scale: isFocused ? 1.2 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: isFocused
                                        ? AppColors.beige
                                        : Colors.white,
                                    boxShadow: isFocused
                                        ? [
                                            BoxShadow(
                                              color: AppColors.beige.withValues(
                                                alpha: 0.6,
                                              ),
                                              blurRadius: 12,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
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
                        ),
                        onKeyEvent: (_, event) {
                          if (event is KeyUpEvent &&
                              (event.logicalKey == LogicalKeyboardKey.enter ||
                                  event.logicalKey ==
                                      LogicalKeyboardKey.select)) {
                            Navigator.pushNamed(
                              context,
                              Routes.video,
                              arguments: {'videoUrl': video},
                            );
                            return KeyEventResult.handled;
                          }
                          return KeyEventResult.ignored;
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        return _buildPlaceholderBanner();
      },
    );
  }

  Widget _buildPlaceholderBanner({String? errorMessage}) {
    return Container(
      height: 300.heightMultiplier,
      width: double.infinity,
      color: AppColors.beige,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, color: AppColors.white, size: 50.textMultiplier),
            8.verticalSpace,
            Text(
              errorMessage ?? 'No banners available for ${widget.category}',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16.textMultiplier,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchIcon() {
    return Focus(
      focusNode: _searchFocusNode,
      onFocusChange: (v) {
        debugPrint('SEARCH BUTTON FOCUS CHANGE = $v');
      },
      child: Builder(
        builder: (context) {
          final isFocused = Focus.of(context).hasFocus;

          return AnimatedScale(
            scale: isFocused ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: GestureDetector(
              onTap: _toggleSearch,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFocused
                      ? AppColors.beige
                      : Colors.white.withValues(alpha: 0.9),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: AppColors.beige.withValues(alpha: 0.6),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Icon(
                  Icons.search,
                  color: isFocused ? AppColors.white : AppColors.black,
                  size: 24,
                ),
              ),
            ),
          );
        },
      ),
      onKeyEvent: (_, event) {
        if (event is KeyUpEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.select)) {
          _toggleSearch();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
    );
  }

  Widget _buildExpandedSearchBar() {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyUpEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          _textFieldFocusNode.requestFocus();
          SystemChannels.textInput.invokeMethod('TextInput.show');
          return KeyEventResult.handled;
        }

        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.escape ||
                event.logicalKey == LogicalKeyboardKey.goBack)) {
          _textFieldFocusNode.unfocus();
          _toggleSearch();
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () {
          _textFieldFocusNode.requestFocus();
          SystemChannels.textInput.invokeMethod('TextInput.show');
        },
        onDoubleTap: _toggleSearch,
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
                    controller: _searchController,
                    focusNode: _textFieldFocusNode,
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
                    onSubmitted: (value) {
                      _handleSearchSubmit();
                      _toggleSearch();
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

// Animation wrapper widget
class AnimatedBannerWrapper extends StatelessWidget {
  final Widget child;

  const AnimatedBannerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
