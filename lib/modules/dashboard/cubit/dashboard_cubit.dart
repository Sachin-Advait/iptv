// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/common/constants/api_constants.dart';
import 'package:oman_tv/common/utils/get_it.dart';
import 'package:oman_tv/models/layout_model.dart';
import 'package:oman_tv/models/ticker_model.dart';
import 'package:oman_tv/services/api_client.dart';
import 'package:oman_tv/services/connectivity_service.dart';
import 'package:oman_tv/services/iptv_socket_service.dart';

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

    _wsManager.onLayoutUpdateReceived = _handleLayoutUpdate;

    _wsManager.onConnectionSuccess = () async {
      debugPrint('[IPTV-WS] ✅ WebSocket connected successfully');

      // Update connection status
      emit(state.copyWith(errorMessage: null));

      // Refresh data after successful connection
      if (_currentTvId != null && state.tickerStatus != TickerStatus.loading) {
        await refreshTickerData();
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

    // Reconnect WebSocket if needed
    if (!_wsManager.isConnected && _currentTvId != null) {
      debugPrint('[DASHBOARD] 🔄 Reconnecting WebSocket');
      Future.delayed(const Duration(seconds: 2), () {
        if (_connectivityService.isConnected) {
          _wsManager.reconnect();
        }
      });
    }

    // Refresh data based on current state
    Future.delayed(const Duration(seconds: 3), () {
      if (_connectivityService.isConnected) {
        if (state.tickerStatus == TickerStatus.error) {
          debugPrint('[DASHBOARD] 🔄 Reloading from error state');
          fetchTickerData();
        } else if (state.tickerStatus == TickerStatus.success) {
          debugPrint('[DASHBOARD] 🔄 Refreshing data');
          refreshTickerData();
        }
      }
    });
  }

  void _handleLayoutUpdate(LayoutModel layout) {
    debugPrint('[DASHBOARD] 🎨 Layout update received');
    debugPrint('[DASHBOARD] 📋 Layout: ${layout.toString()}');

    // Update state with new layout
    emit(state.copyWith(currentLayout: layout));

    // Optionally refresh ticker data if ticker is enabled
    if (layout.tickerEnabled &&
        state.tickerStatus != TickerStatus.loading &&
        _connectivityService.isConnected) {
      debugPrint('[DASHBOARD] 🔄 Ticker enabled - refreshing data');
      refreshTickerData();
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
              state.tickerStatus == TickerStatus.success) {
            debugPrint('[DASHBOARD] 🔄 MESSAGE_TIMEOUT reached - refreshing');
            refreshTickerData();
          }
        }
      }
    });
  }

  void _startDataRefreshTimer() {
    _dataRefreshTimer?.cancel();

    _dataRefreshTimer = Timer.periodic(DATA_REFRESH_INTERVAL, (timer) async {
      if (_connectivityService.isConnected &&
          state.tickerStatus != TickerStatus.loading &&
          state.tickerStatus == TickerStatus.success) {
        debugPrint('[DASHBOARD] ⏰ Periodic data refresh');
        await refreshTickerData();
      } else {
        debugPrint('[DASHBOARD] ⏸️ Skipping refresh - no network or loading');
      }
    });
  }

  void _handleTvUpdate() {
    debugPrint('[DASHBOARD] 📺 TV update received - refreshing ticker data');

    // Refresh ticker data when TV update is received
    if (state.tickerStatus != TickerStatus.loading &&
        _connectivityService.isConnected) {
      refreshTickerData();
    }
  }

  Future<void> fetchTickerData() async {
    // Network check is already handled by ApiClient
    if (!_connectivityService.isConnected) {
      debugPrint('[DASHBOARD] ⏸️ Skipping data load - no network');
      emit(
        state.copyWith(
          tickerStatus: TickerStatus.error,
          errorMessage: 'No internet connection',
        ),
      );
      return;
    }

    emit(
      state.copyWith(tickerStatus: TickerStatus.loading, errorMessage: null),
    );

    try {
      // ApiClient already has retry logic built-in
      final response = await _apiClient.getApi(ApiConstants.tickers);

      if (response != null && response.statusCode == 200) {
        final tickerModel = TickerModel.fromJson(response.data);

        emit(
          state.copyWith(
            tickerStatus: TickerStatus.success,
            tickerData: tickerModel.data,
            errorMessage: null,
          ),
        );

        debugPrint('[DASHBOARD] ✅ Ticker data loaded successfully');
      } else {
        throw Exception('Failed to load ticker data');
      }
    } catch (e, stack) {
      debugPrint('[DASHBOARD] ❌ Failed to load ticker data: $e');
      debugPrint(stack.toString());

      emit(
        state.copyWith(
          tickerStatus: TickerStatus.error,
          errorMessage: 'Failed to load ticker data',
        ),
      );
    }
  }

  Future<void> refreshTickerData() async {
    if (!_connectivityService.isConnected) {
      debugPrint('[DASHBOARD] ⏸️ Skipping refresh - no network');
      return;
    }

    if (state.tickerStatus == TickerStatus.loading) {
      debugPrint('[DASHBOARD] ⏸️ Already loading');
      return;
    }

    try {
      // ApiClient handles retry automatically
      final response = await _apiClient.getApi(ApiConstants.tickers);

      if (response != null && response.statusCode == 200) {
        final tickerModel = TickerModel.fromJson(response.data);

        emit(
          state.copyWith(
            tickerStatus: TickerStatus.success,
            tickerData: tickerModel.data,
            errorMessage: null,
          ),
        );

        debugPrint('[DASHBOARD] ✅ Ticker data refreshed successfully');
      }
    } catch (e, stack) {
      debugPrint('[DASHBOARD] ⚠️ Refresh error: $e');
      debugPrint(stack.toString());

      // Keep current state on error (silent failure)
      // Don't emit error state during refresh to avoid flickering
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
    if (state.tickerStatus == TickerStatus.success) {
      await refreshTickerData();
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
    if (state.tickerStatus == TickerStatus.success) {
      await refreshTickerData();

      if (_currentTvId != null) {
        await _wsManager.reconnect();
      }
    } else {
      await fetchTickerData();
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
