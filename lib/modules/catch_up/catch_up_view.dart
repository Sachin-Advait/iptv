import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/common/constants/api_constants.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/common/widgets/carousel_banner.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/modules/home/cubit/home_cubit.dart';
import 'package:oman_tv/modules/vod/vod_view.dart';
import 'package:oman_tv/modules/vod/widgets/video_card.dart';

class CatchUpView extends StatefulWidget {
  const CatchUpView({super.key});

  @override
  State<CatchUpView> createState() => _CatchUpViewState();
}

class _CatchUpViewState extends State<CatchUpView> implements FocusListener {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().fetchMedia(ApiConstants.home);
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
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
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
          ),
          20.verticalSpace,
          SizedBox(
            height: 120.heightMultiplier,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.widthMultiplier),
              itemCount: row1.length,
              separatorBuilder: (context, index) => 10.horizontalSpace,
              itemBuilder: (context, index) {
                final video = row1[index];

                return VideoCard(
                  rowId: 2,
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
          30.verticalSpace,
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
