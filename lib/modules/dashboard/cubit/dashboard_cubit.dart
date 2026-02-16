// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/common/constants/api_constants.dart';
import 'package:oman_tv/common/utils/get_it.dart';
import 'package:oman_tv/models/dashboard_model.dart';
import 'package:oman_tv/services/api_client.dart';
import 'package:oman_tv/services/connectivity_service.dart';
import 'package:oman_tv/services/iptv_socket_service.dart';
import 'package:oman_tv/services/session_manager.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final ApiClient _apiClient = getIt<ApiClient>();
  final ConnectivityService _connectivityService = getIt<ConnectivityService>();
  late StreamSubscription<bool> _connectivitySubscription;

  final IptvSocketService _wsManager = IptvSocketService();

  Timer? _healthCheckTimer;
  Timer? _dataRefreshTimer;

  String? _currentTvId;

  // Configuration
  static const Duration HEALTH_CHECK_INTERVAL = Duration(seconds: 30);
  static const Duration HEARTBEAT_TIMEOUT = Duration(seconds: 150);
  static const Duration MESSAGE_TIMEOUT = Duration(minutes: 5);
  static const Duration DATA_REFRESH_INTERVAL = Duration(minutes: 2);

  DashboardCubit() : super(const DashboardState()) {
    _setupConnectivityListener();
    _setupWebSocketCallbacks();
  }

  void _setupWebSocketCallbacks() {
    _wsManager.onTvUpdateReceived = _handleTvUpdate;

    _wsManager.onConnectionSuccess = () async {
      debugPrint('[IPTV-WS] ✅ WebSocket connected successfully');

      // Update connection status
      emit(state.copyWith(errorMessage: null));

      // Refresh data after successful connection
      if (_currentTvId != null &&
          state.dashboardStatus != DashboardStatus.loading) {
        await refreshDashboardData();
      }
    };

    _wsManager.onConnectionError = (error) {
      debugPrint('[IPTV-WS] ❌ WebSocket error: $error');
      // Don't emit error - let connectivity service handle it
    };
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivityService.connectionStream.listen((
      isConnected,
    ) {
      emit(state.copyWith(isNetworkConnected: isConnected));

      if (isConnected) {
        debugPrint('[DASHBOARD] 🌐 Internet restored');
        _onConnectivityRestored();
      } else {
        debugPrint('[DASHBOARD] 📵 Internet lost');
      }
    });

    // Set initial connectivity state
    emit(state.copyWith(isNetworkConnected: _connectivityService.isConnected));
  }

  Future<void> _onConnectivityRestored() async {
    // Reset any error messages
    emit(state.copyWith(errorMessage: null));

    // Refresh data based on current state
    Future.delayed(const Duration(seconds: 3), () {
      if (_connectivityService.isConnected) {
        if (state.dashboardStatus == DashboardStatus.error) {
          debugPrint('[DASHBOARD] 🔄 Reloading from error state');
          fetchDashboardData();
        } else if (state.dashboardStatus == DashboardStatus.success) {
          debugPrint('[DASHBOARD] 🔄 Refreshing data');
          refreshDashboardData();
        }
      }
    });
  }

  void _handleTvUpdate() {
    debugPrint('[DASHBOARD] 📺 TV update received - refreshing ticker data');

    // Refresh ticker data when TV update is received
    if (state.dashboardStatus != DashboardStatus.loading &&
        _connectivityService.isConnected) {
      refreshDashboardData();
    }
  }

  Future<void> initializeWebSocket(String tvId) async {
    _currentTvId = tvId;

    if (_connectivityService.isConnected) {
      await _wsManager.connect(tvId);
      _startHealthCheck();
      _startDataRefreshTimer();
    } else {
      debugPrint('[DASHBOARD] ⏸️ Skipping WebSocket init - no network');
    }
  }

  void _startHealthCheck() {
    _healthCheckTimer?.cancel();

    _healthCheckTimer = Timer.periodic(HEALTH_CHECK_INTERVAL, (timer) {
      if (!_connectivityService.isConnected) {
        debugPrint('[DASHBOARD] ⏸️ Health check paused - no network');
        return;
      }

      final now = DateTime.now();
      final lastHeartbeat = _wsManager.lastHeartbeatReceived;
      final lastMessage = _wsManager.lastMessageReceived;

      if (lastHeartbeat != null && lastMessage != null) {
        final timeSinceLastHeartbeat = now.difference(lastHeartbeat);
        final timeSinceLastMessage = now.difference(lastMessage);

        debugPrint(
          '[DASHBOARD] 🔍 Health check - Connected: ${_wsManager.isConnected}, '
          'Last heartbeat: ${timeSinceLastHeartbeat.inSeconds}s, '
          'Last message: ${timeSinceLastMessage.inSeconds}s',
        );

        // Check heartbeat
        if (timeSinceLastHeartbeat > HEARTBEAT_TIMEOUT) {
          debugPrint('[DASHBOARD] ❌ Heartbeat timeout - reconnecting');
          _wsManager.reconnect();
          return;
        }

        // Only refresh data on MESSAGE_TIMEOUT boundary
        if (timeSinceLastMessage > MESSAGE_TIMEOUT && _wsManager.isConnected) {
          final intervalsSinceLastMessage =
              timeSinceLastMessage.inSeconds ~/ HEALTH_CHECK_INTERVAL.inSeconds;
          final intervalsSinceTimeout =
              MESSAGE_TIMEOUT.inSeconds ~/ HEALTH_CHECK_INTERVAL.inSeconds;

          // Only refresh if this is the first check after timeout
          if (intervalsSinceLastMessage == intervalsSinceTimeout &&
              state.dashboardStatus == DashboardStatus.success) {
            debugPrint('[DASHBOARD] 🔄 MESSAGE_TIMEOUT reached - refreshing');
            refreshDashboardData();
          }
        }
      }
    });
  }

  void _startDataRefreshTimer() {
    _dataRefreshTimer?.cancel();

    _dataRefreshTimer = Timer.periodic(DATA_REFRESH_INTERVAL, (timer) async {
      if (_connectivityService.isConnected &&
          state.dashboardStatus != DashboardStatus.loading &&
          state.dashboardStatus == DashboardStatus.success) {
        debugPrint('[DASHBOARD] ⏰ Periodic data refresh');
        await refreshDashboardData();
      } else {
        debugPrint('[DASHBOARD] ⏸️ Skipping refresh - no network or loading');
      }
    });
  }

  Future<void> fetchDashboardData() async {
    return _loadDashboardData(isRefresh: false);
  }

  Future<void> refreshDashboardData() async {
    return _loadDashboardData(isRefresh: true);
  }

  Future<void> _loadDashboardData({required bool isRefresh}) async {
    if (!_connectivityService.isConnected) {
      debugPrint(
        '[DASHBOARD] ⏸️ Skipping ${isRefresh ? 'refresh' : 'data load'} - no network',
      );

      if (!isRefresh) {
        emit(
          state.copyWith(
            dashboardStatus: DashboardStatus.error,
            errorMessage: 'No internet connection',
            isNetworkConnected: false,
          ),
        );
      }
      return;
    }

    if (!isRefresh) {
      emit(
        state.copyWith(
          dashboardStatus: DashboardStatus.loading,
          errorMessage: null,
        ),
      );
    } else {
      if (state.dashboardStatus == DashboardStatus.loading) {
        debugPrint('[DASHBOARD] ⏸️ Already loading');
        return;
      }
    }

    try {
      final response = await _apiClient.getApi(
        ApiConstants.layout,
        queryParameters: {"deviceId": SessionManager.getDeviceId()},
      );

      if (response != null && response.statusCode == 200) {
        final dashboardModel = DashboardModel.fromJson(response.data);

        emit(
          state.copyWith(
            dashboardStatus: DashboardStatus.success,
            dashboardData: dashboardModel.data,
            errorMessage: null,
          ),
        );

        debugPrint(
          '[DASHBOARD] ✅ Dashboard data ${isRefresh ? 'refreshed' : 'loaded'} successfully',
        );
      } else {
        throw Exception('Failed to load ticker data');
      }
    } catch (e, stack) {
      debugPrint('[DASHBOARD] ❌ ${isRefresh ? 'Refresh' : 'Load'} failed: $e');
      debugPrint(stack.toString());

      if (!isRefresh) {
        emit(
          state.copyWith(
            dashboardStatus: DashboardStatus.error,
            errorMessage: 'Failed to load ticker data',
          ),
        );
      }
    }
  }

  Future<void> onAppResumed() async {
    debugPrint('[DASHBOARD] 📱 App resumed');

    // Check network status
    final isConnected = await _connectivityService.checkConnection();
    emit(state.copyWith(isNetworkConnected: isConnected));

    if (!isConnected) {
      debugPrint('[DASHBOARD] ⏸️ No network on resume');
      return;
    }

    // Refresh data if we have it
    if (state.dashboardStatus == DashboardStatus.success) {
      await refreshDashboardData();
    }

    // Reconnect WebSocket if needed
    if (!_wsManager.isConnected && _currentTvId != null) {
      await _wsManager.reconnect();
    }
  }

  Future<void> manualRetry() async {
    debugPrint('[DASHBOARD] 🔄 Manual retry requested');

    // Check network status
    final isConnected = await _connectivityService.checkConnection();
    emit(state.copyWith(isNetworkConnected: isConnected));

    if (!isConnected) {
      debugPrint('[DASHBOARD] ⏸️ No network available');
      return;
    }

    // Reset WebSocket attempts
    _wsManager.resetAttempts();

    // Refresh or reload data
    if (state.dashboardStatus == DashboardStatus.success) {
      await refreshDashboardData();

      if (_currentTvId != null) {
        await _wsManager.reconnect();
      }
    } else {
      await fetchDashboardData();
    }
  }

  @override
  Future<void> close() {
    // Cancel all timers
    _healthCheckTimer?.cancel();
    _dataRefreshTimer?.cancel();
    _connectivitySubscription.cancel();

    // Clean up WebSocket
    _wsManager.dispose();

    return super.close();
  }
}
