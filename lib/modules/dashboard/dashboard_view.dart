import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/common/utils/get_it.dart';
import 'package:oman_tv/common/widgets/carousel_banner.dart';
import 'package:oman_tv/common/widgets/flutter_toast.dart';
import 'package:oman_tv/common/widgets/video_player.dart';
import 'package:oman_tv/configs/lang/localization_cubit.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/modules/annoucement/annoucement_view.dart';
import 'package:oman_tv/modules/catch_up/catch_up_view.dart';
import 'package:oman_tv/modules/dashboard/cubit/dashboard_cubit.dart';
import 'package:oman_tv/modules/dashboard/widgets/custom_error.dart';
import 'package:oman_tv/modules/dashboard/widgets/header.dart';
import 'package:oman_tv/modules/dashboard/widgets/network_overlay.dart';
import 'package:oman_tv/modules/dashboard/widgets/ticker_state.dart';
import 'package:oman_tv/modules/home/home_view.dart';
import 'package:oman_tv/modules/live_tv/live_tv_view.dart';
import 'package:oman_tv/modules/meeting_tv/bloc/meeting_tv_bloc.dart';
import 'package:oman_tv/modules/meeting_tv/pages/meeting_tv.dart';
import 'package:oman_tv/modules/radio/radio_view.dart';
import 'package:oman_tv/modules/visitor_tv/cubit/visitor_tv_cubit.dart';
import 'package:oman_tv/modules/visitor_tv/pages/visitor_tv.dart';
import 'package:oman_tv/modules/vod/vod_view.dart';
import 'package:oman_tv/services/session_manager.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with WidgetsBindingObserver
    implements FocusListener {
  final _focusNode = RecentFocusNode(group: FocusGroup.root);

  late DashboardCubit _dashboardCubit;
  bool _isInitialized = false;
  bool _wasShowingError = false;

  List page = [
    const HomeView(),
    const LiveTVView(),
    const VodView(),
    const CatchUpView(),
    const RadioView(),
    const AnnouncementView(),
  ];

  int selectedTabIndex = 0;
  bool isUserSelected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _dashboardCubit = context.read<DashboardCubit>();
    FocusListener.add(this);

    _initializeDashboard();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FocusListener.remove(this);
    super.dispose();
  }

  Future<void> _initializeDashboard() async {
    if (_isInitialized) return;

    try {
      // Get TV ID from configuration
      final tvId = SessionManager.getTvId();

      debugPrint('[DASHBOARD] 🚀 Initializing dashboard for TV: $tvId');

      await _dashboardCubit.fetchDashboardData();
      // Initialize WebSocket connection
      await _dashboardCubit.initializeWebSocket(tvId);

      _isInitialized = true;
      debugPrint('[DASHBOARD] ✅ Dashboard initialized successfully');
    } catch (e) {
      debugPrint('[DASHBOARD] ❌ Error initializing dashboard: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('[DASHBOARD] 📱 App resumed - reconnecting and refreshing');
        _dashboardCubit.onAppResumed();
        break;
      case AppLifecycleState.paused:
        debugPrint('[DASHBOARD] 📱 App paused');
        break;
      case AppLifecycleState.inactive:
        debugPrint('[DASHBOARD] 📱 App inactive');
        break;
      case AppLifecycleState.detached:
        debugPrint('[DASHBOARD] 📱 App detached');
        break;
      case AppLifecycleState.hidden:
        debugPrint('[DASHBOARD] 📱 App hidden');
        break;
    }
  }

  Future<void> changeOr() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        debugPrint('Back blocked on Dashboard');
      },
      child: Scaffold(
        body: BlocConsumer<DashboardCubit, DashboardState>(
          listener: (context, state) {
            // Show network restored message
            if (state.wasNetworkRestored) {
              flutterToast(
                message: 'Network connection restored',
                color: AppColors.green,
              );
            }

            // 🔥 Detect transition from error to normal state
            final isShowingError =
                !state.isNetworkConnected &&
                state.dashboardStatus == DashboardStatus.error;

            if (_wasShowingError && !isShowingError) {
              // Just came back from error screen
              debugPrint('🔴 RETURNING FROM ERROR - RESETTING FOCUS');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  // Reset to header
                  RecentFocusTraversalPolicy.moveToHeaderStart();
                }
              });
            }

            _wasShowingError = isShowingError;
          },
          builder: (context, state) {
            // 🔴 Full-screen error
            if (!state.isNetworkConnected &&
                state.dashboardStatus == DashboardStatus.error) {
              return CustomError(
                message: state.errorMessage ?? 'No internet connection',
                isNetworkError: true,
                onRetry: () => _dashboardCubit.manualRetry(),
              );
            }

            final layout = state.dashboardData?.layout;

            if (state.dashboardData?.profileName == "ServeIQ") {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(create: (context) => getIt<VisitorTvCubit>()),
                  BlocProvider(
                    create: (context) => LocalizationCubit()..initialize(),
                  ),
                ],
                child: VisitorTvPage(
                  videoUrl:
                      state.dashboardData?.videoZone != null &&
                          state.dashboardData!.videoZone.isNotEmpty
                      ? state.dashboardData?.videoZone[0].videoUrl
                      : null,
                ),
              );
            }
            if (state.dashboardData?.profileName == "Meeting") {
              return BlocProvider(
                create: (context) => getIt<MeetingTvBloc>(),
                child: MeetingTvPage(
                  videoUrl:
                      state.dashboardData?.videoZone != null &&
                          state.dashboardData!.videoZone.isNotEmpty
                      ? state.dashboardData?.videoZone[0].videoUrl
                      : null,
                ),
              );
            }
            changeOr();
            if (layout?.name == "Banner Layout") {
              return _buildBannerLayout(state);
            }

            if (layout?.name == "Video Layout") {
              return _buildVideoLayout(state);
            }

            if (layout?.name == "Banner and Ticker Layout") {
              return _buildBannerWithTickerLayout(state);
            }

            // 🔁 Existing dashboard UI remains unchanged for other layouts
            return Stack(
              children: [
                Focus(
                  focusNode: _focusNode,
                  descendantsAreFocusable: true,
                  child: Column(
                    children: <Widget>[
                      if (state.dashboardData != null &&
                          (state.dashboardData!.tickerZone.isNotEmpty) &&
                          state
                                  .dashboardData
                                  ?.layout
                                  .configJson
                                  .tickerZone
                                  ?.position !=
                              'bottom')
                        Expanded(child: NewsTicker()),
                      FocusTraversalGroup(
                        policy: const RecentFocusTraversalPolicy(
                          group: FocusGroup.header,
                        ),
                        child: Header(
                          currentIndex: selectedTabIndex,
                          userSelected: isUserSelected,
                        ),
                      ),

                      Expanded(
                        child: isUserSelected
                            ? const SizedBox()
                            : page[selectedTabIndex],
                      ),
                      if (state.dashboardData != null &&
                          (state.dashboardData!.tickerZone.isNotEmpty) &&
                          state
                                  .dashboardData
                                  ?.layout
                                  .configJson
                                  .tickerZone
                                  ?.position ==
                              'bottom')
                        NewsTicker(),
                    ],
                  ),
                ),

                if (!state.isNetworkConnected &&
                    state.dashboardStatus == DashboardStatus.success)
                  NetworkOverlay(dashboardCubit: _dashboardCubit),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void onFocusChanged(FocusGroup group, int row, int column) {
    if (group == FocusGroup.header) {
      setState(() {
        // if (column < page.length) {
        //   selectedTabIndex = column;
        //   isUserSelected = false;
        // } else {
        //   isUserSelected = true;
        // }
        selectedTabIndex = column;
      });
    }
  }

  Widget _buildBannerLayout(DashboardState state) {
    final bannerZone = state.dashboardData?.bannerZone ?? [];

    // 🖼️ Case 2: Full screen banners
    if (bannerZone.isNotEmpty) {
      return Scaffold(
        body: CarouselBanner(
          category: bannerZone.first.category ?? "",
          height: double.infinity,
          showSearch: false,
        ),
      );
    }

    return const Scaffold(body: Center(child: Text("No media available")));
  }

  Widget _buildVideoLayout(DashboardState state) {
    final videoZone = state.dashboardData?.videoZone ?? [];

    if (videoZone.isNotEmpty && videoZone.first.videoUrl != null) {
      return VideoView(videoUrl: videoZone.first.videoUrl!);
    }

    return const Scaffold(body: Center(child: Text("No media available")));
  }

  Widget _buildBannerWithTickerLayout(DashboardState state) {
    final bannerZone = state.dashboardData?.bannerZone ?? [];
    final tickerItems = state.dashboardData?.tickerZone ?? [];

    return Scaffold(
      body: Column(
        children: [
          if (tickerItems.isNotEmpty &&
              state.dashboardData?.layout.configJson.tickerZone?.position !=
                  'bottom')
            Expanded(child: NewsTicker()),

          CarouselBanner(
            category: bannerZone.first.category ?? "",
            height: MediaQuery.of(context).size.height * .91,
            showSearch: false,
          ),
          if (tickerItems.isNotEmpty &&
              state.dashboardData?.layout.configJson.tickerZone?.position ==
                  'bottom')
            Expanded(child: NewsTicker()),
        ],
      ),
    );
  }
}
