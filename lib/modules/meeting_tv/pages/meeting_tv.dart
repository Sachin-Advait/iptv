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
    changeOr();
    _currentTime = DateTime.now();

    // Load data — bloc handles WS + periodic refresh internally
    context.read<MeetingTvBloc>().add(LoadTvDisplayData());

    // Clock timer
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  Future<void> changeOr() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
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
            // ── 1. Full-screen error — never loaded successfully ─────────────
            if (state is TvDisplayError) {
              return OrderErrorView(
                message: state.message,
                isNetworkError: state.isNetworkError,
                onRetry: () =>
                    context.read<MeetingTvBloc>().add(ManualRetryEvent()),
                color: AppColors.white,
              );
            }

            // ── 2. Loaded UI — banner overlaid if network drops ──────────────
            if (state is TvDisplayLoaded) {
              return Stack(
                children: [
                  _TvContent(
                    tvData: state.tvDisplayDetails,
                    currentTime: _currentTime,
                    fadeDuration: fadeDuration,
                    videoUrl: widget.videoUrl,
                  ),

                  // Network-drop banner over content — never replaces it
                  if (!state.isNetworkConnected)
                    const NoInternetBanner(top: 60),
                ],
              );
            }

            // ── 3. Initial loading ───────────────────────────────────────────
            return EmptyContent();
          },
        ),
      ),
    );
  }
}

// =============================================================================
// TV content — extracted so the Stack stays readable
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
    final currentRooms = tvData.currentRooms ?? [];
    final bookedRooms = currentRooms.where((r) => r.booked!).toList();
    final freeRooms = currentRooms.where((r) => !r.booked!).toList();
    final upcomingRooms = tvData.upcomingRooms ?? [];
    final statistics = tvData.statistics;

    final bookedCount = statistics?.busyRooms ?? bookedRooms.length;
    final freeCount = statistics?.freeRooms ?? freeRooms.length;

    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor = screenHeight / 1920;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 10),

        // ── Header ────────────────────────────────────────────────────────────
        _TvHeader(currentTime: currentTime, scaleFactor: scaleFactor),

        SizedBox(
          height: bookedCount == 0 ? 10 * scaleFactor : 20 * scaleFactor,
        ),

        // ── Stats ─────────────────────────────────────────────────────────────
        _TvStatRow(
          bookedCount: bookedCount,
          freeCount: freeCount,
          bookedRoomsLength: bookedRooms.length,
          scaleFactor: scaleFactor,
        ),

        SizedBox(
          height: bookedCount == 0 ? 30 * scaleFactor : 40 * scaleFactor,
        ),

        // ── Main content ──────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22 * scaleFactor),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CurrentMeetings(
                showBusyRooms: bookedRooms.isNotEmpty,
                bookedRooms: bookedRooms,
                freeRooms: freeRooms,
                fadeDuration: fadeDuration,
              ),
              SizedBox(width: 28 * scaleFactor),
              Expanded(
                child: UpcomingMeetings(
                  upcomingRoom: upcomingRooms,
                  fadeDuration: fadeDuration,
                  busyRooms: bookedRooms,
                ),
              ),
            ],
          ),
        ),

        // ── Video ─────────────────────────────────────────────────────────────
        if (videoUrl != null && (videoUrl?.isNotEmpty ?? false))
          Container(
            height: screenHeight * .24,
            padding: EdgeInsets.symmetric(horizontal: 22 * scaleFactor),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: VideoView(videoUrl: videoUrl!),
            ),
          ),

        SizedBox(height: 20 * scaleFactor),

        // ── News ticker ───────────────────────────────────────────────────────
        NewsTicker(color: AppColors.white),

        SizedBox(height: 20 * scaleFactor),
      ],
    );
  }
}

// =============================================================================
// Header
// =============================================================================

class _TvHeader extends StatelessWidget {
  const _TvHeader({required this.currentTime, required this.scaleFactor});

  final DateTime currentTime;
  final double scaleFactor;

  String formatDate(DateTime date) {
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

    String weekday = weekdays[date.weekday - 1];
    String month = months[date.month - 1];

    return '$weekday, $month ${date.day}';
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
                '${currentTime.hour.toString().padLeft(2, '0')} : ${currentTime.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 26 * scaleFactor,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              Text(
                formatDate(currentTime),
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
// Stat row
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

// =============================================================================
// News ticker
// =============================================================================

// class NewsTicker extends StatefulWidget {
//   final double scaleFactor;

//   const NewsTicker({super.key, required this.scaleFactor});

//   @override
//   State<NewsTicker> createState() => _NewsTickerState();
// }

// class _NewsTickerState extends State<NewsTicker> {
//   late ScrollController _scrollController;
//   Timer? _scrollTimer;

//   final List<String> newsItems = [
//     'Welcome to the Military and Security Services Pension Fund. We are happy to serve you.',
//     'مرحبا بكم في صندوق تقاعد الأجهزة العسكرية والأمنية ، يسعدنا خدمتكم',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
//   }

//   void _startAutoScroll() {
//     _scrollTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
//       if (_scrollController.hasClients) {
//         final maxScroll = _scrollController.position.maxScrollExtent;
//         final currentScroll = _scrollController.offset;

//         if (currentScroll >= maxScroll) {
//           _scrollController.jumpTo(0);
//         } else {
//           _scrollController.animateTo(
//             currentScroll + 3,
//             duration: const Duration(milliseconds: 30),
//             curve: Curves.linear,
//           );
//         }
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _scrollTimer?.cancel();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final newsText = newsItems.join('    -    ');
//     final displayText = '$newsText    -    $newsText    -    $newsText';

//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 22 * widget.scaleFactor),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(15 * widget.scaleFactor),
//         child: SingleChildScrollView(
//           controller: _scrollController,
//           reverse: true,
//           scrollDirection: Axis.horizontal,
//           physics: const NeverScrollableScrollPhysics(),
//           child: Container(
//             alignment: Alignment.center,
//             padding: EdgeInsets.symmetric(horizontal: 20 * widget.scaleFactor),
//             child: Text(
//               displayText,
//               style: TextStyle(
//                 fontSize: 45 * widget.scaleFactor,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.white,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
