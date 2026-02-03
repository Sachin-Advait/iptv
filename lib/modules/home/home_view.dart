// modules/home/home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/common/constants/api_constants.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/common/widgets/carousel_banner.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';
import 'package:oman_tv/modules/home/cubit/home_cubit.dart';
import 'package:oman_tv/modules/home/widget/section_data.dart';
import 'package:oman_tv/modules/home/widget/section_row.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> implements FocusListener {
  int? _selectedLiveTvIndex;
  String? _selectedLiveTvName;
  bool _liveTvHeaderMode = false;

  @override
  void initState() {
    super.initState();
    FocusListener.add(this);
    context.read<HomeCubit>().fetchMedia(ApiConstants.home);
  }

  @override
  void onFocusChanged(FocusGroup group, int row, int column) {
    if (group == FocusGroup.header) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    FocusListener.remove(this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: ListView(
            children: [
              FocusTraversalGroup(
                policy: const RecentFocusTraversalPolicy(
                  group: FocusGroup.button,
                ),
                child: CarouselBanner(
                  onSearch: (query) {
                    // Handle search functionality
                    debugPrint('Search query: $query');
                  },
                ),
              ),
              20.verticalSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 24.widthMultiplier),
                    child: Text(
                      'Live TV Group',
                      style: context.bold.copyWith(
                        fontSize: 18.textMultiplier,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  LiveTVSection(
                    rowId: 0,
                    isHeaderMode: _liveTvHeaderMode,
                    selectedIndex: _selectedLiveTvIndex,
                    onCategorySelected: (index, name) {
                      setState(() {
                        _selectedLiveTvIndex = index;
                        _selectedLiveTvName = name;
                        _liveTvHeaderMode = true;
                      });
                    },
                  ),
                  if (_liveTvHeaderMode) ...[
                    10.verticalSpace,
                    Padding(
                      padding: EdgeInsets.only(left: 24.widthMultiplier),
                      child: Text(
                        _selectedLiveTvName!,
                        style: context.bold.copyWith(
                          fontSize: 18.textMultiplier,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    DynamicLiveTVSection(
                      categoryIndex: _selectedLiveTvIndex!,
                      rowId: 1,
                    ),
                  ],
                  Padding(
                    padding: EdgeInsets.only(left: 24.widthMultiplier),
                    child: Text(
                      'Radio Group',
                      style: context.bold.copyWith(
                        fontSize: 18.textMultiplier,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  RadioSection(
                    rowId: _liveTvHeaderMode ? 2 : 1,
                    items: HomeSectionData.radioItems,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 24.widthMultiplier),
                    child: Text(
                      'Announcement',
                      style: context.bold.copyWith(
                        fontSize: 18.textMultiplier,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  AnnouncementSection(rowId: _liveTvHeaderMode ? 3 : 2),
                ],
              ),
              10.verticalSpace,
            ],
          ),
        );
      },
    );
  }
}
