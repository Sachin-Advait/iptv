// common/widgets/carousel_banner.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/common/widgets/banner_place_holder.dart';
import 'package:oman_tv/common/widgets/banner_search_icon.dart';
import 'package:oman_tv/common/widgets/banner_shimmer.dart';
import 'package:oman_tv/common/widgets/expanded_search_bar.dart';
import 'package:oman_tv/common/widgets/play_button.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/models/dashboard_model.dart';
import 'package:oman_tv/modules/dashboard/cubit/dashboard_cubit.dart';

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
          return BannerPlaceHolder(
            widget: widget,
            errorMessage: state.errorMessage,
          );
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
            return BannerPlaceHolder(widget: widget);
          }

          // Get all image URLs from category banners
          final allImageUrls = categoryBanners
              .expand((banner) => banner.imageUrls ?? [])
              .toList();

          if (allImageUrls.isEmpty) {
            return BannerPlaceHolder(widget: widget);
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
                        ? ExpandedSearchBar(
                            controller: _searchController,
                            textFieldFocusNode: _textFieldFocusNode,
                            onClose: _toggleSearch,
                            onSubmit: _handleSearchSubmit,
                          )
                        : BannerSearchIcon(
                            focusNode: _searchFocusNode,
                            onToggle: _toggleSearch,
                          ),
                  ),

                  // Play Button (only if video exists for category)
                  if (video != null)
                    VideoPlayButton(
                      playFocusNode: _playFocusNode,
                      video: video,
                    ),
                ],
              ),
            ),
          );
        }

        return BannerPlaceHolder(widget: widget);
      },
    );
  }
}
