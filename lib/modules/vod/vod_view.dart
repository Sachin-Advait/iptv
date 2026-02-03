import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/common/constants/api_constants.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/common/widgets/carousel_banner.dart';
import 'package:oman_tv/configs/assets/app_banner.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/modules/home/cubit/home_cubit.dart';
import 'package:oman_tv/modules/vod/widgets/video_card.dart';

class VodView extends StatefulWidget {
  const VodView({super.key});

  @override
  State<VodView> createState() => _VodViewState();
}

class _VodViewState extends State<VodView> implements FocusListener {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().fetchMedia(ApiConstants.vod);
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
            child: CarouselBanner(),
          ),
          20.verticalSpace,
          SizedBox(
            height: 120.heightMultiplier,
            child: FocusTraversalGroup(
              policy: RecentFocusTraversalPolicy(group: FocusGroup.listRow),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.widthMultiplier),
                itemCount: row1.length,
                separatorBuilder: (context, index) => 10.horizontalSpace,
                itemBuilder: (context, index) {
                  final video = row1[index];

                  return VideoCard(
                    rowId: 0,
                    columnId: index,
                    imageUrl: video.imageUrl,
                    title: video.title,
                    description: video.description,
                    duration: video.duration,
                    onTap: () {},
                  );
                },
              ),
            ),
          ),
          20.verticalSpace,
          SizedBox(
            height: 120.heightMultiplier,
            child: FocusTraversalGroup(
              policy: RecentFocusTraversalPolicy(group: FocusGroup.listRow),
              child: Stack(
                children: [
                  ListView.separated(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    padding: EdgeInsets.symmetric(horizontal: 20.widthMultiplier),
                    itemCount: row2.length,
                    separatorBuilder: (context, index) => 10.horizontalSpace,
                    itemBuilder: (context, index) {
                      final video = row2[index];
                      return VideoCard(
                        rowId: 1,
                        columnId: index,
                        imageUrl: video.imageUrl,
                        title: video.title,
                        description: video.description,
                        duration: video.duration,
                        onTap: () {},
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Data model for video
class VideoData {
  final String imageUrl;
  final String title;
  final String description;
  final String duration;

  const VideoData({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.duration,
  });
}

// Example data
final List<VideoData> row1 = [
  VideoData(
    imageUrl: AppBanner.person05,
    title: 'Qualifiers to Represent Oman at Geneva International Exhibition',
    description:
        'The Research and Innovation Authority announced the qualifiers who will represent Oman...',
    duration: '15:05',
  ),
  VideoData(
    imageUrl: AppBanner.video01,
    title: 'Israeli Occupation Arrests 10 Palestinians in West Bank',
    description:
        'The Israeli occupation forces (IOF) arrested today ten Palestinians from different areas...',
    duration: '10:15',
  ),
  VideoData(
    imageUrl: AppBanner.video02,
    title: 'Oil Prices Gain on Upbeat China Data',
    description:
        'Oil prices rose during today\'s trading, supported by positive economic data from China...',
    duration: '13:25',
  ),
];

// Example data
final List<VideoData> row2 = [
  VideoData(
    imageUrl: AppBanner.person06,
    title: 'Workshop Discusses Governance, Mecha...',
    description: 'he Ministry of Commerce, Industry and Investment ...',
    duration: '09:05',
  ),
  VideoData(
    imageUrl: AppBanner.person07,
    title: 'Medical City for Military and Security Ser...',
    description: 'The Medical City for Military and Security Services to...',
    duration: '12:15',
  ),
  VideoData(
    imageUrl: AppBanner.person08,
    title: 'OCCI Organizes Workshop on Greater ...',
    description: 'Oman Chamber of Commerce and Industry (OCCI), ...',
    duration: '25:15',
  ),
];
