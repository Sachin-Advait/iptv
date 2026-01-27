import 'package:flutter/material.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/common/widgets/carousel_banner.dart';
import 'package:oman_tv/configs/assets/app_banner.dart';
import 'package:oman_tv/configs/assets/app_channels.dart';
import 'package:oman_tv/configs/assets/app_images.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';
import 'package:oman_tv/modules/home/widget/announcement_card.dart';
import 'package:oman_tv/modules/home/widget/category_card.dart';
import 'package:oman_tv/modules/home/widget/group_card.dart';
import 'package:oman_tv/modules/home/widget/vlc_player_page.dart';

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
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        children: [
          FocusTraversalGroup(
            policy: const RecentFocusTraversalPolicy(group: FocusGroup.button),
            child: CarouselBanner(
              banners: AppBanner.homeBanners,
              onPlayPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const VideoScreen();
                    },
                  ),
                );
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
              LiveTVGroup(
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
                DynamicLiveTVRow(
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
              RadioGroup(rowId: _liveTvHeaderMode ? 2 : 1),
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
  }
}

class DynamicLiveTVRow extends StatelessWidget {
  final int categoryIndex;
  final int rowId;

  const DynamicLiveTVRow({
    super.key,
    required this.categoryIndex,
    required this.rowId,
  });

  List<RadioItem> get _group1Items => [
    RadioItem(imagePath: AppChannels.bbc),
    RadioItem(imagePath: AppChannels.cnn),
    RadioItem(imagePath: AppChannels.cbs),
    RadioItem(imagePath: AppChannels.sky),
  ];

  List<RadioItem> get _group2Items => [
    RadioItem(imagePath: AppChannels.omanAir),
    RadioItem(imagePath: AppChannels.channel1),
    RadioItem(imagePath: AppChannels.pngegg),
    RadioItem(imagePath: AppChannels.ubc2),
  ];

  List<RadioItem> get _group3Items => [
    RadioItem(imagePath: AppChannels.bein),
    RadioItem(imagePath: AppChannels.fox),
    RadioItem(imagePath: AppChannels.star),
    RadioItem(imagePath: AppChannels.tenSports),
  ];

  List<RadioItem> get _group4Items => [
    RadioItem(imagePath: AppChannels.channel1),
    RadioItem(imagePath: AppChannels.cbs),
    RadioItem(imagePath: AppChannels.star),
    RadioItem(imagePath: AppChannels.omanAir),
  ];

  List<RadioItem> _getItems() {
    switch (categoryIndex) {
      case 0: // News
        return _group1Items;
      case 1: // Government
        return _group2Items;
      case 2: // Sports
        return _group3Items;
      default:
        return _group4Items;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _getItems();

    return SizedBox(
      height: 120.heightMultiplier,
      child: FocusTraversalGroup(
        policy: RecentFocusTraversalPolicy(group: FocusGroup.listRow),
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: 20.widthMultiplier,
            vertical: 20.heightMultiplier,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => 12.horizontalSpace,
          itemBuilder: (context, index) {
            final item = items[index];
            return GroupCard(
              rowId: rowId,
              columnId: index,
              item: item,
              onTap: item.onTap,
            );
          },
        ),
      ),
    );
  }
}

class LiveTVGroup extends StatelessWidget {
  final int rowId;
  final bool isHeaderMode;
  final int? selectedIndex;
  final Function(int index, String name)? onCategorySelected;

  const LiveTVGroup({
    super.key,
    required this.rowId,
    required this.isHeaderMode,
    required this.selectedIndex,
    this.onCategorySelected,
  });

  Widget _buildItem({
    required BuildContext context,
    required int index,
    required String icon,
    required String label,
  }) {
    final bool isSelected = isHeaderMode && selectedIndex == index;

    return CategoryCard(
      rowId: rowId,
      columnId: index,
      icon: icon,
      label: label,
      isHeaderStyle: isHeaderMode,
      isSelected: isSelected,
      // onTap: () => onCategorySelected?.call(index, label),
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isHeaderMode ? 70.heightMultiplier : 120.heightMultiplier,
      child: FocusTraversalGroup(
        policy: RecentFocusTraversalPolicy(
          group: isHeaderMode ? FocusGroup.liveHeader : FocusGroup.listRow,
        ),

        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: 20.widthMultiplier,
            vertical: isHeaderMode ? 10.heightMultiplier : 20.heightMultiplier,
          ),
          scrollDirection: Axis.horizontal,
          children: [
            _buildItem(
              context: context,
              index: 0,
              icon: AppImages.news,
              label: 'News',
            ),
            12.horizontalSpace,
            _buildItem(
              context: context,
              index: 1,
              icon: AppImages.government,
              label: 'Government',
            ),
            12.horizontalSpace,
            _buildItem(
              context: context,
              index: 2,
              icon: AppImages.sports,
              label: 'Sports',
            ),
            12.horizontalSpace,
            _buildItem(
              context: context,
              index: 3,
              icon: AppImages.internal,
              label: 'Internal',
            ),
            20.horizontalSpace,
          ],
        ),
      ),
    );
  }
}

class AnnouncementSection extends StatelessWidget {
  final int rowId;

  const AnnouncementSection({super.key, required this.rowId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.heightMultiplier,
      child: FocusTraversalGroup(
        policy: const RecentFocusTraversalPolicy(group: FocusGroup.listRow),
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: 20.widthMultiplier,
            vertical: 20.heightMultiplier,
          ),
          scrollDirection: Axis.horizontal,
          children: [
            AnnouncementCard(
              rowId: rowId,
              columnId: 0,
              icon: AppImages.meetingRoom,
              label: 'Meeting Room',
              onTap: () => debugPrint("Meeting Room tapped"),
            ),
            12.horizontalSpace,
            AnnouncementCard(
              rowId: rowId,
              columnId: 1,
              icon: AppImages.visitorManagement,
              label: 'Visitor Management',
              onTap: () => debugPrint("Visitor Management tapped"),
            ),
            12.horizontalSpace,
            AnnouncementCard(
              rowId: rowId,
              columnId: 2,
              icon: AppImages.ramadan,
              label: 'Ramadan',
              onTap: () => debugPrint("Ramadan tapped"),
            ),
          ],
        ),
      ),
    );
  }
}

class RadioGroup extends StatelessWidget {
  final int rowId;
  final EdgeInsets? padding;
  final VoidCallback? onItemPressed;

  const RadioGroup({
    super.key,
    required this.rowId,
    this.padding,
    this.onItemPressed,
  });

  List<RadioItem> get _radioItems => [
    RadioItem(imagePath: AppChannels.ubc),
    RadioItem(imagePath: AppChannels.omanAir),
    RadioItem(imagePath: AppChannels.merge),
    RadioItem(imagePath: AppChannels.jld),
    RadioItem(imagePath: AppChannels.omanAir),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.heightMultiplier,
      child: FocusTraversalGroup(
        policy: const RecentFocusTraversalPolicy(group: FocusGroup.listRow),
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: 20.widthMultiplier,
            vertical: 20.heightMultiplier,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: _radioItems.length,
          separatorBuilder: (context, index) => 12.horizontalSpace,
          itemBuilder: (context, index) {
            final item = _radioItems[index];
            return GroupCard(
              rowId: rowId,
              columnId: index,
              item: item,
              onTap: onItemPressed ?? item.onTap,
            );
          },
        ),
      ),
    );
  }
}
