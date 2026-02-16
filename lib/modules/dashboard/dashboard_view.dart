import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/common/widgets/flutter_toast.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/modules/annoucement/annoucement_view.dart';
import 'package:oman_tv/modules/catch_up/catch_up_view.dart';
import 'package:oman_tv/modules/dashboard/cubit/dashboard_cubit.dart';
import 'package:oman_tv/modules/dashboard/widgets/custom_error.dart';
import 'package:oman_tv/modules/dashboard/widgets/header.dart';
import 'package:oman_tv/modules/dashboard/widgets/ticker_state.dart';
import 'package:oman_tv/modules/home/home_view.dart';
import 'package:oman_tv/modules/live_tv/live_tv_view.dart';
import 'package:oman_tv/modules/radio/radio_view.dart';
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

    // Initialize dashboard with WebSocket and data fetching
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    if (_isInitialized) return;

    try {
      // Get TV ID from configuration
      final tvId = SessionManager.getTvId();

      debugPrint('[DASHBOARD] 🚀 Initializing dashboard for TV: $tvId');

      // Initialize WebSocket connection
      await _dashboardCubit.initializeWebSocket(tvId);

      // Fetch initial ticker data
      await _dashboardCubit.fetchTickerData();

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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FocusListener.remove(this);
    super.dispose();
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
          },
          builder: (context, state) {
            // Full-screen error when no internet and no cached data
            if (!state.isNetworkConnected &&
                state.tickerStatus == TickerStatus.error) {
              return CustomError(
                message: state.errorMessage ?? 'No internet connection',
                isNetworkError: true,
                onRetry: () => _dashboardCubit.manualRetry(),
              );
            }

            // Normal UI with optional network indicator overlay
            return Stack(
              children: [
                Focus(
                  focusNode: _focusNode,
                  descendantsAreFocusable: true,
                  child: Column(
                    children: <Widget>[
                      // Header
                      FocusTraversalGroup(
                        policy: const RecentFocusTraversalPolicy(
                          group: FocusGroup.header,
                        ),
                        child: Header(
                          currentIndex: selectedTabIndex,
                          userSelected: isUserSelected,
                        ),
                      ),

                      // Content
                      Expanded(
                        child: isUserSelected
                            ? const SizedBox()
                            : page[selectedTabIndex],
                      ),
                      NewsTicker(),
                    ],
                  ),
                ),

                // Network status overlay (like TVDisplayScreen)
                // Shows when content is playing but internet is low/lost
                if (!state.isNetworkConnected &&
                    state.tickerStatus == TickerStatus.success)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'No Internet Connection',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _dashboardCubit.manualRetry(),
                            child: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
}
