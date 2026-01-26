import 'package:flutter/material.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/common/widgets/carousel_banner.dart';
import 'package:oman_tv/configs/assets/app_banner.dart';
import 'package:oman_tv/configs/assets/app_channels.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';
import 'package:oman_tv/modules/home/widget/group_card.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        children: [
          FocusTraversalGroup(
            policy: const RecentFocusTraversalPolicy(group: FocusGroup.button),
            child: CarouselBanner(
              banners: [AppBanner.person02, AppBanner.person08],
              onPlayPressed: () {
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) {
                //       return const VideoScreen();
                //     },
                //   ),
                // );
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
                  'News',
                  style: context.bold.copyWith(
                    fontSize: 18.textMultiplier,
                    color: AppColors.black,
                  ),
                ),
              ),
              12.verticalSpace,
              RadioGroup(rowId: 0, items: _group1Items),
              20.verticalSpace,
              Padding(
                padding: EdgeInsets.only(left: 20.widthMultiplier),
                child: Text(
                  'Government',
                  style: context.bold.copyWith(
                    fontSize: 18.textMultiplier,
                    color: AppColors.black,
                  ),
                ),
              ),
              12.verticalSpace,
              RadioGroup(rowId: 1, items: _group2Items),
              20.verticalSpace,
              Padding(
                padding: EdgeInsets.only(left: 20.widthMultiplier),
                child: Text(
                  'Sports',
                  style: context.bold.copyWith(
                    fontSize: 18.textMultiplier,
                    color: AppColors.black,
                  ),
                ),
              ),
              12.verticalSpace,
              RadioGroup(rowId: 2, items: _group3Items),
            ],
          ),
          30.verticalSpace,
        ],
      ),
    );
  }
}

class RadioGroup extends StatelessWidget {
  final int rowId;
  final VoidCallback? onItemPressed;
  final List<RadioItem> items;

  const RadioGroup({
    super.key,
    required this.rowId,
    required this.items,
    this.onItemPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82.heightMultiplier,
      child: FocusTraversalGroup(
        policy: const RecentFocusTraversalPolicy(group: FocusGroup.listRow),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20),
          itemCount: items.length,
          separatorBuilder: (context, index) => 12.horizontalSpace,
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
