// modules/home/home_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/common/widgets/video_player.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/models/tv_display_response.dart';
import 'package:oman_tv/modules/dashboard/widgets/ticker_state.dart';
import 'package:oman_tv/modules/meeting_tv/bloc/meeting_tv_bloc.dart';
import 'package:oman_tv/modules/meeting_tv/pages/components/current_meetings.dart';
import 'package:oman_tv/modules/meeting_tv/pages/components/empty_content.dart';
import 'package:oman_tv/modules/meeting_tv/pages/components/no_internet_banner.dart';
import 'package:oman_tv/modules/meeting_tv/pages/components/order_error_view.dart';
import 'package:oman_tv/modules/meeting_tv/pages/components/stat_badge.dart';
import 'package:oman_tv/modules/meeting_tv/pages/components/upcoming_meetings.dart';

class MeetingTvPage extends StatefulWidget {
  const MeetingTvPage({super.key, required this.videoUrl});

  final String? videoUrl;

  @override
  State<MeetingTvPage> createState() => _MeetingTvPageState();
}

class _MeetingTvPageState extends State<MeetingTvPage>
    with WidgetsBindingObserver {
  late DateTime _currentTime;
  Timer? _clockTimer;

  static const Duration fadeDuration = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _unlockAllOrientations();
    _currentTime = DateTime.now();

    context.read<MeetingTvBloc>().add(LoadTvDisplayData());

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  /// Allow both portrait and landscape so the OS can rotate freely.
  Future<void> _unlockAllOrientations() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      context.read<MeetingTvBloc>().add(const OnAppResumedEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/2.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocConsumer<MeetingTvBloc, TvDisplayState>(
          listener: (context, state) {
            if (state is TvDisplayError) {
              debugPrint('🎯 BLOC LISTENER - Error: ${state.message}');
            }
          },
          builder: (context, state) {
            if (state is TvDisplayError) {
              return OrderErrorView(
                message: state.message,
                isNetworkError: state.isNetworkError,
                onRetry: () =>
                    context.read<MeetingTvBloc>().add(ManualRetryEvent()),
                color: AppColors.white,
              );
            }

            if (state is TvDisplayLoaded) {
              return Stack(
                children: [
                  _TvContent(
                    tvData: state.tvDisplayDetails,
                    currentTime: _currentTime,
                    fadeDuration: fadeDuration,
                    videoUrl: widget.videoUrl,
                  ),
                  if (!state.isNetworkConnected)
                    const NoInternetBanner(top: 60),
                ],
              );
            }

            return EmptyContent();
          },
        ),
      ),
    );
  }
}

// =============================================================================
// TV content — orientation-aware
// =============================================================================

class _TvContent extends StatelessWidget {
  const _TvContent({
    required this.tvData,
    required this.currentTime,
    required this.fadeDuration,
    required this.videoUrl,
  });

  final TvDisplayDetails tvData;
  final DateTime currentTime;
  final Duration fadeDuration;
  final String? videoUrl;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return isLandscape
        ? _LandscapeLayout(
            tvData: tvData,
            currentTime: currentTime,
            fadeDuration: fadeDuration,
            videoUrl: videoUrl,
          )
        : _PortraitLayout(
            tvData: tvData,
            currentTime: currentTime,
            fadeDuration: fadeDuration,
            videoUrl: videoUrl,
          );
  }
}

// =============================================================================
// Shared data helper
// =============================================================================

class _TvData {
  _TvData(TvDisplayDetails tvData)
    : bookedRooms = (tvData.currentRooms ?? [])
          .where((r) => r.booked!)
          .toList(),
      freeRooms = (tvData.currentRooms ?? []).where((r) => !r.booked!).toList(),
      upcomingRooms = tvData.upcomingRooms ?? [],
      statistics = tvData.statistics;

  final List<Room> bookedRooms;
  final List<Room> freeRooms;
  final List<Room> upcomingRooms;
  final dynamic statistics;

  int get bookedCount => statistics?.busyRooms ?? bookedRooms.length;
  int get freeCount => statistics?.freeRooms ?? freeRooms.length;
}

// =============================================================================
// LANDSCAPE layout  (wide screen — original portrait design rotated)
// =============================================================================

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout({
    required this.tvData,
    required this.currentTime,
    required this.fadeDuration,
    required this.videoUrl,
  });

  final TvDisplayDetails tvData;
  final DateTime currentTime;
  final Duration fadeDuration;
  final String? videoUrl;

  @override
  Widget build(BuildContext context) {
    final d = _TvData(tvData);
    final size = MediaQuery.of(context).size;

    // Scale against 1024 logical-px landscape height baseline (iPad landscape).
    final scaleFactor = size.height / 1024;

    final hasVideo = videoUrl != null && (videoUrl?.isNotEmpty ?? false);

    return Column(
      children: [
        // ── Header ────────────────────────────────────────────────────────────
        SizedBox(height: 8 * scaleFactor),
        _TvHeader(currentTime: currentTime, scaleFactor: scaleFactor),
        SizedBox(height: 8 * scaleFactor),

        // ── Stats row ─────────────────────────────────────────────────────────
        _TvStatRow(
          bookedCount: d.bookedCount,
          freeCount: d.freeCount,
          bookedRoomsLength: d.bookedRooms.length,
          scaleFactor: scaleFactor,
        ),
        SizedBox(height: 10 * scaleFactor),

        // ── Main content (fills remaining space) ──────────────────────────────
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left — current / available rooms
                Expanded(
                  flex: 3,
                  child: CurrentMeetings(
                    showBusyRooms: d.bookedRooms.isNotEmpty,
                    bookedRooms: d.bookedRooms,
                    freeRooms: d.freeRooms,
                    fadeDuration: fadeDuration,
                  ),
                ),
                SizedBox(width: 16 * scaleFactor),
                // Right — upcoming + optional video stacked vertically
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Expanded(
                        child: UpcomingMeetings(
                          upcomingRoom: d.upcomingRooms,
                          fadeDuration: fadeDuration,
                          busyRooms: d.bookedRooms,
                        ),
                      ),
                      if (hasVideo) ...[
                        SizedBox(height: 10 * scaleFactor),
                        SizedBox(
                          height: size.height * 0.32,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
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

        SizedBox(height: 8 * scaleFactor),

        // ── News ticker ───────────────────────────────────────────────────────
        NewsTicker(color: AppColors.white),
        SizedBox(height: 8 * scaleFactor),
      ],
    );
  }
}

// =============================================================================
// PORTRAIT layout  (original vertical design — unchanged logic)
// =============================================================================

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({
    required this.tvData,
    required this.currentTime,
    required this.fadeDuration,
    required this.videoUrl,
  });

  final TvDisplayDetails tvData;
  final DateTime currentTime;
  final Duration fadeDuration;
  final String? videoUrl;

  @override
  Widget build(BuildContext context) {
    final d = _TvData(tvData);
    final size = MediaQuery.of(context).size;
    final scaleFactor = size.height / 1920;

    final hasVideo = videoUrl != null && (videoUrl?.isNotEmpty ?? false);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 10),
        _TvHeader(currentTime: currentTime, scaleFactor: scaleFactor),
        SizedBox(
          height: d.bookedCount == 0 ? 10 * scaleFactor : 20 * scaleFactor,
        ),
        _TvStatRow(
          bookedCount: d.bookedCount,
          freeCount: d.freeCount,
          bookedRoomsLength: d.bookedRooms.length,
          scaleFactor: scaleFactor,
        ),
        SizedBox(
          height: d.bookedCount == 0 ? 30 * scaleFactor : 40 * scaleFactor,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22 * scaleFactor),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CurrentMeetings(
                showBusyRooms: d.bookedRooms.isNotEmpty,
                bookedRooms: d.bookedRooms,
                freeRooms: d.freeRooms,
                fadeDuration: fadeDuration,
              ),
              SizedBox(width: 28 * scaleFactor),
              Expanded(
                child: UpcomingMeetings(
                  upcomingRoom: d.upcomingRooms,
                  fadeDuration: fadeDuration,
                  busyRooms: d.bookedRooms,
                ),
              ),
            ],
          ),
        ),
        if (hasVideo)
          Container(
            height: size.height * .24,
            padding: EdgeInsets.symmetric(horizontal: 22 * scaleFactor),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: VideoView(videoUrl: videoUrl!),
            ),
          ),
        SizedBox(height: 20 * scaleFactor),
        NewsTicker(color: AppColors.white),
        SizedBox(height: 20 * scaleFactor),
      ],
    );
  }
}

// =============================================================================
// Header  (shared)
// =============================================================================

class _TvHeader extends StatelessWidget {
  const _TvHeader({required this.currentTime, required this.scaleFactor});

  final DateTime currentTime;
  final double scaleFactor;

  String _formatDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * scaleFactor),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset('assets/images/logo.png', height: 40 * scaleFactor),
          SizedBox(width: 16 * scaleFactor),
          Text(
            'MSSPF',
            style: TextStyle(
              fontSize: 34 * scaleFactor,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${currentTime.hour.toString().padLeft(2, '0')} : '
                '${currentTime.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 26 * scaleFactor,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              Text(
                _formatDate(currentTime),
                style: TextStyle(
                  fontSize: 16 * scaleFactor,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white75,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Stat row  (shared)
// =============================================================================

class _TvStatRow extends StatelessWidget {
  const _TvStatRow({
    required this.bookedCount,
    required this.freeCount,
    required this.bookedRoomsLength,
    required this.scaleFactor,
  });

  final int bookedCount;
  final int freeCount;
  final int bookedRoomsLength;
  final double scaleFactor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (bookedRoomsLength == 1 || bookedRoomsLength == 0) ...[
          SizedBox(width: 30 * scaleFactor),
          StatBadge(
            icon: 'assets/images/coworking.png',
            count: freeCount.toString(),
            color: AppColors.green,
            label: 'Free',
          ),
          SizedBox(width: 30 * scaleFactor),
        ],
        StatBadge(
          icon: 'assets/images/coworking.png',
          count: bookedCount.toString(),
          color: AppColors.red,
          label: 'Busy',
        ),
        if (bookedRoomsLength > 1) ...[
          SizedBox(width: 30 * scaleFactor),
          StatBadge(
            icon: 'assets/images/coworking.png',
            count: freeCount.toString(),
            color: AppColors.green,
            label: 'Free',
          ),
        ],
      ],
    );
  }
}
