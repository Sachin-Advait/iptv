import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/common/widgets/carousel_banner.dart';
import 'package:oman_tv/configs/assets/app_banner.dart';
import 'package:oman_tv/configs/assets/app_channels.dart';
import 'package:oman_tv/configs/assets/app_images.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';
import 'package:oman_tv/modules/home/widget/group_card.dart';
import 'package:oman_tv/modules/home/widget/vlc_player_page.dart';

class LiveTVView extends StatefulWidget {
  const LiveTVView({super.key});

  @override
  State<LiveTVView> createState() => _LiveTVViewState();
}

class _LiveTVViewState extends State<LiveTVView> implements FocusListener {
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

          // Live TV Group - Row 0
          Padding(
            padding: EdgeInsets.only(left: 20.widthMultiplier),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live TV Group',
                  style: context.bold.copyWith(
                    fontSize: 18.textMultiplier,
                    color: AppColors.black,
                  ),
                ),
                16.verticalSpace,
                LiveTVGroup(rowId: 0),
              ],
            ),
          ),

          24.verticalSpace,

          // Radio Group - Row 1
          Padding(
            padding: EdgeInsets.only(left: 20.widthMultiplier),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Radio Group',
                  style: context.bold.copyWith(
                    fontSize: 18.textMultiplier,
                    color: AppColors.black,
                  ),
                ),
                16.verticalSpace,
                GenericRadioGroup(
                  rowId: 1,
                  items: _radioItems,
                  backgroundColor: AppColors.lightBeige,
                  focusedBackgroundColor: AppColors.beige,
                  onItemPressed: () {
                    debugPrint("Radio item pressed");
                  },
                ),
              ],
            ),
          ),

          24.verticalSpace,

          // Announcement - Row 2
          Padding(
            padding: EdgeInsets.only(left: 20.widthMultiplier),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Announcement',
                  style: context.bold.copyWith(
                    fontSize: 18.textMultiplier,
                    color: AppColors.black,
                  ),
                ),
                16.verticalSpace,
                AnnouncementSection(rowId: 2),
              ],
            ),
          ),

          30.verticalSpace,
        ],
      ),
    );
  }

  List<RadioItem> get _radioItems => [
    RadioItem(imagePath: AppChannels.ubc),
    RadioItem(imagePath: AppChannels.omanNews),
    RadioItem(imagePath: AppChannels.merge),
    RadioItem(imagePath: AppChannels.jld),
    RadioItem(imagePath: AppChannels.omanNews),
  ];
}

class LiveTVGroup extends StatelessWidget {
  final int rowId;

  const LiveTVGroup({super.key, required this.rowId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82.heightMultiplier,
      child: FocusTraversalGroup(
        policy: const RecentFocusTraversalPolicy(group: FocusGroup.listRow),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            CategoryCard(
              rowId: rowId,
              columnId: 0,
              icon: AppImages.news,
              label: 'News',
              onTap: () {},
            ),
            12.horizontalSpace,
            CategoryCard(
              rowId: rowId,
              columnId: 1,
              icon: AppImages.government,
              label: 'Government',
              onTap: () {},
            ),
            12.horizontalSpace,
            CategoryCard(
              rowId: rowId,
              columnId: 2,
              icon: AppImages.sports,
              label: 'Sports',
              onTap: () {},
            ),
            12.horizontalSpace,
            CategoryCard(
              rowId: rowId,
              columnId: 3,
              icon: AppImages.internal,
              label: 'Internal',
              onTap: () {},
            ),
            20.horizontalSpace,
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatefulWidget {
  final int rowId;
  final int columnId;
  final String icon;
  final String label;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.rowId,
    required this.columnId,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  final RecentFocusNode _focusNode = RecentFocusNode(group: FocusGroup.listRow);

  @override
  Widget build(BuildContext context) {
    _focusNode.row = widget.rowId;
    _focusNode.column = widget.columnId;

    return GestureDetector(
      onTap: () {
        RecentFocusTraversalPolicy.setFocus(_focusNode, true);
        widget.onTap();
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.rowId == 0 && widget.columnId == 0,
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;

            return Container(
              alignment: Alignment.center,
              width: 230.widthMultiplier,
              padding: EdgeInsets.symmetric(
                horizontal: 10.widthMultiplier,
                vertical: 16.heightMultiplier,
              ),
              decoration: BoxDecoration(
                color: isFocused ? AppColors.primary : AppColors.beige,
                borderRadius: BorderRadius.circular(16.radiusMultipier),
                border: isFocused
                    ? Border.all(color: AppColors.white, width: 3)
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    widget.icon,
                    width: 40.widthMultiplier,
                    height: 40.heightMultiplier,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  25.horizontalSpace,
                  Text(
                    widget.label,
                    style: context.semiBold.copyWith(
                      fontSize: 20.textMultiplier,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        onKeyEvent: (_, event) {
          if (event is KeyUpEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.select)) {
            widget.onTap();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
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
      height: 82.heightMultiplier,
      child: FocusTraversalGroup(
        policy: const RecentFocusTraversalPolicy(group: FocusGroup.listRow),
        child: ListView(
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

class AnnouncementCard extends StatefulWidget {
  final int rowId;
  final int columnId;
  final String icon;
  final String label;
  final VoidCallback? onTap;

  const AnnouncementCard({
    super.key,
    required this.rowId,
    required this.columnId,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  State<AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<AnnouncementCard> {
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

            return Container(
              width: 230.widthMultiplier,
              padding: EdgeInsets.all(20.widthMultiplier),
              decoration: BoxDecoration(
                color: isFocused
                    ? AppColors.beige.withValues(alpha: .6)
                    : AppColors.lightBeige,
                borderRadius: BorderRadius.circular(16.radiusMultipier),
                border: isFocused
                    ? Border.all(color: AppColors.primary, width: 3)
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    widget.icon,
                    width: 50.widthMultiplier,
                    height: 50.heightMultiplier,
                    colorFilter: ColorFilter.mode(
                      AppColors.beige.withValues(alpha: 0.6),
                      BlendMode.srcIn,
                    ),
                  ),
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: context.semiBold.copyWith(
                      fontSize: 14.textMultiplier,
                      color: AppColors.primary,
                    ),
                  ),
                ],
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

class GenericRadioGroup extends StatelessWidget {
  final int rowId;
  final List<RadioItem> items;
  final double height;
  final double itemWidth;
  final double spacing;
  final EdgeInsets? padding;
  final Color backgroundColor;
  final Color focusedBackgroundColor;
  final double borderRadius;
  final BoxFit imageFit;
  final VoidCallback? onItemPressed;

  const GenericRadioGroup({
    super.key,
    required this.rowId,
    required this.items,
    this.height = 82,
    this.itemWidth = 230,
    this.spacing = 12,
    this.padding,
    this.backgroundColor = AppColors.lightBeige,
    this.focusedBackgroundColor = AppColors.beige,
    this.borderRadius = 16,
    this.imageFit = BoxFit.contain,
    this.onItemPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height.heightMultiplier,
      child: FocusTraversalGroup(
        policy: const RecentFocusTraversalPolicy(group: FocusGroup.listRow),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: padding,
          itemCount: items.length,
          separatorBuilder: (context, index) => spacing.horizontalSpace,
          itemBuilder: (context, index) {
            final item = items[index];
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
