import 'package:flutter/material.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/common/widgets/carousel_banner.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';
import 'package:oman_tv/modules/home/widget/section_data.dart';
import 'package:oman_tv/modules/home/widget/section_row.dart';

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
            child: CarouselBanner(category: 'Live TV'),
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
              RadioSection(rowId: 0, items: HomeSectionData.group1Items),
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
              RadioSection(rowId: 1, items: HomeSectionData.group2Items),
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
              RadioSection(rowId: 2, items: HomeSectionData.group3Items),
            ],
          ),
          30.verticalSpace,
        ],
      ),
    );
  }
}
