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
  bool _wasShowingError = false;
  late ScrollController _tickerScrollController;
  Timer? _tickerTimer;

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

    _tickerScrollController = ScrollController();
    _dashboardCubit = context.read<DashboardCubit>();
    FocusListener.add(this);

    _initializeDashboard();
  }

  void _startTickerAutoScroll() {
    _tickerTimer?.cancel();

    _tickerTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (_tickerScrollController.hasClients) {
        final max = _tickerScrollController.position.maxScrollExtent;
        final current = _tickerScrollController.offset;

        if (current >= max) {
          _tickerScrollController.jumpTo(0);
        } else {
          _tickerScrollController.jumpTo(current + 2);
        }
      }
    });
  }

  void _stopTickerAutoScroll() {
    _tickerTimer?.cancel();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _tickerScrollController.dispose();
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
              _stopTickerAutoScroll();

              return CustomError(
                message: state.errorMessage ?? 'No internet connection',
                isNetworkError: true,
                onRetry: () => _dashboardCubit.manualRetry(),
              );
            }

            // 🟢 Normal UI
            final tickerItems = state.dashboardData?.tickerZone ?? [];

            if (state.dashboardStatus == DashboardStatus.success &&
                tickerItems.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _startTickerAutoScroll();
              });
            } else {
              _stopTickerAutoScroll();
            }

            return Stack(
              children: [
                Focus(
                  focusNode: _focusNode,
                  descendantsAreFocusable: true,
                  child: Column(
                    children: <Widget>[
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

                      // 📰 Ticker UI only
                      NewsTicker(
                        items: tickerItems,
                        controller: _tickerScrollController,
                      ),
                    ],
                  ),
                ),

                if (!state.isNetworkConnected &&
                    state.dashboardStatus == DashboardStatus.success)
                  _buildNetworkOverlay(),
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

  Positioned _buildNetworkOverlay() {
    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, color: Colors.white, size: 20),
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
              child: const Icon(Icons.refresh, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
