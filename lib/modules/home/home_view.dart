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
                padding: EdgeInsets.only(left: 20.widthMultiplier),
                child: Text(
                  'Live TV Group',
                  style: context.bold.copyWith(
                    fontSize: 18.textMultiplier,
                    color: AppColors.black,
                  ),
                ),
              ),
              LiveTVGroup(rowId: 0),
              Padding(
                padding: EdgeInsets.only(left: 20.widthMultiplier),
                child: Text(
                  'Radio Group',
                  style: context.bold.copyWith(
                    fontSize: 18.textMultiplier,
                    color: AppColors.black,
                  ),
                ),
              ),
              RadioGroup(rowId: 1),
              Padding(
                padding: EdgeInsets.only(left: 20.widthMultiplier),
                child: Text(
                  'Announcement',
                  style: context.bold.copyWith(
                    fontSize: 18.textMultiplier,
                    color: AppColors.black,
                  ),
                ),
              ),
              AnnouncementSection(rowId: 2),
            ],
          ),
          30.verticalSpace,
        ],
      ),
    );
  }
}

class LiveTVGroup extends StatelessWidget {
  final int rowId;

  const LiveTVGroup({super.key, required this.rowId});

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
