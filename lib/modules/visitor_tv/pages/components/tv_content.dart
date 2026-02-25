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

  bool get _hasVideo => videoUrl != null && (videoUrl?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return isLandscape
        ? _LandscapeContent(
            isRTL: isRTL,
            currentTime: _currentTime,
            scaleFactor: scaleFactor,
            tvState: tvState,
            videoUrl: videoUrl,
            hasVideo: _hasVideo,
          )
        : _PortraitContent(
            isRTL: isRTL,
            currentTime: _currentTime,
            scaleFactor: scaleFactor,
            tvState: tvState,
            videoUrl: videoUrl,
            hasVideo: _hasVideo,
          );
  }
}

// =============================================================================
// PORTRAIT — original layout, untouched
// =============================================================================

class _PortraitContent extends StatelessWidget {
  const _PortraitContent({
    required this.isRTL,
    required this.currentTime,
    required this.scaleFactor,
    required this.tvState,
    required this.videoUrl,
    required this.hasVideo,
  });

  final bool isRTL;
  final DateTime currentTime;
  final double scaleFactor;
  final TVDisplayLoaded tvState;
  final String? videoUrl;
  final bool hasVideo;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            children: [
              Header(
                scaleFactor: scaleFactor,
                currentTime: currentTime,
                isRTL: isRTL,
              ),
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
                          : 150 * scaleFactor,
                      child: QueueSummary(
                        upcomingTokens: tvState.upcomingTokens,
                        scaleFactor: scaleFactor,
                      ),
                    ),
                    if (tvState.holdTokens.isNotEmpty) ...[
                      SizedBox(width: 10 * scaleFactor),
                      SizedBox(
                        width: 150 * scaleFactor,
                        child: HoldTokens(
                          upcomingTokens: tvState.holdTokens,
                          scaleFactor: scaleFactor,
                        ),
                      ),
                    ],
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
        if (hasVideo)
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

// =============================================================================
// LANDSCAPE — floor plan + video side by side, fills screen height
// =============================================================================
class _LandscapeContent extends StatelessWidget {
  const _LandscapeContent({
    required this.isRTL,
    required this.currentTime,
    required this.scaleFactor,
    required this.tvState,
    required this.videoUrl,
    required this.hasVideo,
  });

  final bool isRTL;
  final DateTime currentTime;
  final double scaleFactor;
  final TVDisplayLoaded tvState;
  final String? videoUrl;
  final bool hasVideo;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Scale factor based on landscape height baseline (iPad landscape ~834px)
    final lsScale = size.height / 834;

    return Column(
      children: [
        // ── Header ─────────────────────────────────────────────────────────
        Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Header(
            scaleFactor: lsScale,
            currentTime: currentTime,
            isRTL: isRTL,
          ),
        ),

        // ── Now Calling banner ──────────────────────────────────────────────
        if (tvState.latestCalls.isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(
              8 * lsScale,
              8 * lsScale,
              8 * lsScale,
              0,
            ),
            child: NowCalling(calls: tvState.latestCalls, scaleFactor: lsScale),
          ),

        SizedBox(height: 6 * lsScale),

        // ── Main area ────────────────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8 * lsScale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Directionality(
                    textDirection: isRTL
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: NowServing(
                            nowServing: tvState.nowServing,
                            scaleFactor: lsScale,
                            height: double.infinity,
                          ),
                        ),
                        SizedBox(width: 8 * lsScale),
                        SizedBox(
                          width: tvState.holdTokens.isEmpty
                              ? 350 * lsScale
                              : 250 * lsScale,
                          child: QueueSummary(
                            upcomingTokens: tvState.upcomingTokens,
                            scaleFactor: lsScale,
                            height: double.infinity,
                          ),
                        ),
                        if (tvState.holdTokens.isNotEmpty) ...[
                          SizedBox(width: 8 * lsScale),
                          SizedBox(
                            width: 250 * lsScale,
                            child: HoldTokens(
                              upcomingTokens: tvState.holdTokens,
                              scaleFactor: lsScale,
                              height: double.infinity,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20 * lsScale),

                // ── Floor plan + video side by side ───────────────────────────
                Expanded(
                  child: Row(
                    children: [
                      // Floor plan
                      Expanded(
                        flex: hasVideo ? 35 : 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedFloorPlan(
                            imagePath: AppImages.topView,
                          ),
                        ),
                      ),

                      // Video (side by side with floor plan)
                      if (hasVideo) ...[
                        SizedBox(width: 18 * lsScale),
                        Expanded(
                          flex: 45,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: VideoView(videoUrl: videoUrl!),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 8 * lsScale),
        NewsTicker(),
        SizedBox(height: 6 * lsScale),
      ],
    );
  }
}
