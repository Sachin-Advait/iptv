import 'package:flutter/material.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/modules/home/widget/announcement_card.dart';
import 'package:oman_tv/modules/home/widget/category_card.dart';
import 'package:oman_tv/modules/home/widget/group_card.dart';
import 'package:oman_tv/modules/home/widget/section_data.dart';

class DynamicLiveTVSection extends StatelessWidget {
  final int categoryIndex;
  final int rowId;

  const DynamicLiveTVSection({
    super.key,
    required this.categoryIndex,
    required this.rowId,
  });

  @override
  Widget build(BuildContext context) {
    final items = HomeSectionData.dynamicLiveTVItems(categoryIndex);

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

class LiveTVSection extends StatelessWidget {
  final int rowId;
  final bool isHeaderMode;
  final int? selectedIndex;
  final Function(int index, String name)? onCategorySelected;

  const LiveTVSection({
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
      onTap: () => onCategorySelected?.call(index, label),
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
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: 20.widthMultiplier,
            vertical: isHeaderMode ? 10.heightMultiplier : 20.heightMultiplier,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: HomeSectionData.liveTVitems.length,
          separatorBuilder: (context, index) => 12.horizontalSpace,
          itemBuilder: (context, index) {
            final item = HomeSectionData.liveTVitems[index];
            return _buildItem(
              context: context,
              index: index,
              icon: item['icon']!,
              label: item['label']!,
            );
          },
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
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: 20.widthMultiplier,
            vertical: 20.heightMultiplier,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: HomeSectionData.announcements.length,
          separatorBuilder: (context, index) => 12.horizontalSpace,
          itemBuilder: (context, index) {
            final announcement = HomeSectionData.announcements[index];
            return AnnouncementCard(
              rowId: rowId,
              columnId: index,
              icon: announcement['icon'] as String,
              label: announcement['label'] as String,
              onTap: announcement['onTap'] as VoidCallback,
            );
          },
        ),
      ),
    );
  }
}

class RadioSection extends StatelessWidget {
  final int rowId;
  final EdgeInsets? padding;
  final VoidCallback? onItemPressed;

  const RadioSection({
    super.key,
    required this.rowId,
    this.padding,
    this.onItemPressed,
  });

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
          itemCount: HomeSectionData.radioItems.length,
          separatorBuilder: (context, index) => 12.horizontalSpace,
          itemBuilder: (context, index) {
            final item = HomeSectionData.radioItems[index];
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
