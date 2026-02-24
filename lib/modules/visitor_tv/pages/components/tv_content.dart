import 'package:flutter/material.dart';
import 'package:oman_tv/common/widgets/video_player.dart';
import 'package:oman_tv/configs/assets/app_images.dart';
import 'package:oman_tv/modules/dashboard/widgets/ticker_state.dart';
import 'package:oman_tv/modules/visitor_tv/cubit/visitor_tv_cubit.dart';
import 'package:oman_tv/modules/visitor_tv/pages/components/animated_floor_plan.dart';
import 'package:oman_tv/modules/visitor_tv/pages/components/header.dart';
import 'package:oman_tv/modules/visitor_tv/pages/components/hold_tokens.dart';
import 'package:oman_tv/modules/visitor_tv/pages/components/now_calling.dart';
import 'package:oman_tv/modules/visitor_tv/pages/components/now_serving.dart';
import 'package:oman_tv/modules/visitor_tv/pages/components/queue_summary.dart';

class TVContent extends StatelessWidget {
  const TVContent({
    super.key,
    required this.isRTL,
    required DateTime currentTime,
    required this.scaleFactor,
    required this.tvState,
    this.videoUrl,
  }) : _currentTime = currentTime;

  final bool isRTL;
  final DateTime _currentTime;
  final double scaleFactor;
  final TVDisplayLoaded tvState;
  final String? videoUrl;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            children: [
              // Header section
              Header(
                scaleFactor: scaleFactor,
                currentTime: _currentTime,
                isRTL: isRTL,
              ),

              // Now Calling section
              if (tvState.latestCalls.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    8 * scaleFactor,
                    12 * scaleFactor,
                    8 * scaleFactor,
                    0,
                  ),
                  child: NowCalling(
                    calls: tvState.latestCalls,
                    scaleFactor: scaleFactor,
                  ),
                ),

              SizedBox(height: 4 * scaleFactor),

              // Main content area
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * scaleFactor),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: NowServing(
                        nowServing: tvState.nowServing,
                        scaleFactor: scaleFactor,
                      ),
                    ),
                    SizedBox(width: 10 * scaleFactor),
                    SizedBox(
                      width: tvState.holdTokens.isEmpty
                          ? 200 * scaleFactor
                          : 100 * scaleFactor,
                      child: QueueSummary(
                        upcomingTokens: tvState.upcomingTokens,
                        scaleFactor: scaleFactor,
                      ),
                    ),
                    if (tvState.holdTokens.isNotEmpty)
                      SizedBox(width: 10 * scaleFactor),
                    if (tvState.holdTokens.isNotEmpty)
                      SizedBox(
                        width: 100 * scaleFactor,
                        child: HoldTokens(
                          upcomingTokens: tvState.holdTokens,
                          scaleFactor: scaleFactor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12 * scaleFactor),
        AnimatedFloorPlan(
          imagePath: AppImages.topView,
          height: 290 * scaleFactor,
        ),
        SizedBox(height: 14 * scaleFactor),

        if (videoUrl != null && (videoUrl?.isNotEmpty ?? false))
          Container(
            height: MediaQuery.of(context).size.height * .24,
            padding: EdgeInsets.symmetric(horizontal: 8 * scaleFactor),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: VideoView(videoUrl: videoUrl!),
            ),
          ),
        SizedBox(height: 5 * scaleFactor),

        NewsTicker(),
      ],
    );
  }
}
