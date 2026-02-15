// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/common/constants/api_constants.dart';
import 'package:oman_tv/common/utils/get_it.dart';
import 'package:oman_tv/models/ticker_model.dart';
import 'package:oman_tv/services/api_client.dart';
import 'package:oman_tv/services/iptv_socket_service.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final ApiClient _apiClient = getIt<ApiClient>();
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final IptvSocketService _wsManager = IptvSocketService();

  Timer? _healthCheckTimer;
  Timer? _dataRefreshTimer;
  Timer? _networkRetryTimer;

  String? _currentTvId;
  int _apiRetryAttempts = 0;
  bool _shouldReconnect = true;
  bool _isNetworkAvailable = true;

  // Configuration
  static const int MAX_API_RETRY_ATTEMPTS = 10;
  static const Duration HEALTH_CHECK_INTERVAL = Duration(seconds: 30);
  static const Duration HEARTBEAT_TIMEOUT = Duration(seconds: 150);
  static const Duration NETWORK_RETRY_INTERVAL = Duration(seconds: 10);
  static const Duration MESSAGE_TIMEOUT = Duration(minutes: 5);
  static const Duration DATA_REFRESH_INTERVAL = Duration(minutes: 2);

  DashboardCubit() : super(DashboardState()) {
    _initializeConnectivityListener();
    _setupWebSocketCallbacks();
  }

  void _setupWebSocketCallbacks() {
    _wsManager.onTvUpdateReceived = _handleTvUpdate;
    _wsManager.onConnectionSuccess = () async {
      debugPrint('[IPTV-WS] ✅ WebSocket connected successfully');

      // Update connection status
      emit(state.copyWith(errorMessage: null, wasNetworkRestored: false));

      // Refresh data after successful connection
      if (_currentTvId != null && state.tickerStatus != TickerStatus.loading) {
        await refreshTickerData();
      }
    };

    _wsManager.onConnectionError = (error) {
      debugPrint('[IPTV-WS] ❌ WebSocket error: $error');
      emit(state.copyWith(errorMessage: error));
    };
  }

  void _initializeConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final result = results.isNotEmpty
          ? results.last
          : ConnectivityResult.none;
      _handleNetworkConnectivityChanged(result);
    });

    // Check initial connectivity
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final result = connectivityResults.isNotEmpty
          ? connectivityResults.last
          : ConnectivityResult.none;
      _handleNetworkConnectivityChanged(result);
    } catch (e) {
      debugPrint('[IPTV-NETWORK] Error checking initial connectivity: $e');
    }
  }

  Future<void> _handleNetworkConnectivityChanged(
    ConnectivityResult result,
  ) async {
    final isConnected = result != ConnectivityResult.none;
    final previouslyConnected = _isNetworkAvailable;

    _isNetworkAvailable = isConnected;
    _wsManager.updateNetworkStatus(isConnected);

    emit(
      state.copyWith(
        isNetworkConnected: isConnected,
        connectivityStatus: result,
      ),
    );

    // Handle network state changes
    if (isConnected && !previouslyConnected) {
      debugPrint('[IPTV-NETWORK] ✅ Network connection restored');

      // Cancel any network retry timer
      _networkRetryTimer?.cancel();
      _networkRetryTimer = null;

      emit(state.copyWith(wasNetworkRestored: true, errorMessage: null));

      // Reset retry attempts when network comes back
      _apiRetryAttempts = 0;
      _wsManager.resetAttempts();

      // Auto-reconnect WebSocket
      if (!_wsManager.isConnected && _currentTvId != null) {
        debugPrint(
          '[IPTV-NETWORK] 🔄 Auto-reconnecting WebSocket after network restore',
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (_isNetworkAvailable) {
            _wsManager.reconnect();
          }
        });
      }

      // Refresh data when network comes back
      Future.delayed(const Duration(seconds: 3), () {
        if (_isNetworkAvailable) {
          if (state.tickerStatus == TickerStatus.error) {
            debugPrint('[IPTV-NETWORK] 🔄 Reloading from error state');
            fetchTickerData();
          } else if (state.tickerStatus == TickerStatus.success) {
            refreshTickerData();
          }
        }
      });
    } else if (!isConnected && previouslyConnected) {
      debugPrint('[IPTV-NETWORK] ❌ Network connection lost');

      emit(
        state.copyWith(
          wasNetworkRestored: false,
          errorMessage: 'No internet connection',
        ),
      );

      // Schedule network retry check
      _scheduleNetworkRetry();
    }
  }

  void _scheduleNetworkRetry() {
    if (!_shouldReconnect) return;

    _networkRetryTimer?.cancel();

    _networkRetryTimer = Timer.periodic(NETWORK_RETRY_INTERVAL, (timer) async {
      try {
        final results = await _connectivity.checkConnectivity();
        final result = results.isNotEmpty
            ? results.last
            : ConnectivityResult.none;

        if (result != ConnectivityResult.none) {
          debugPrint('[IPTV-NETWORK] ✅ Network detected during retry check');
          timer.cancel();
          _handleNetworkConnectivityChanged(result);
        } else {
          debugPrint('[IPTV-NETWORK] 🔄 Still waiting for network...');
        }
      } catch (e) {
        debugPrint('[IPTV-NETWORK] ❌ Error checking network: $e');
      }
    });
  }

  Future<void> initializeWebSocket(String tvId) async {
    _currentTvId = tvId;
    _shouldReconnect = true;

    if (_isNetworkAvailable) {
      await _wsManager.connect(tvId);
      _startHealthCheck();
      _startDataRefreshTimer();
    } else {
      debugPrint('[IPTV-WS] ⏸️ Skipping WebSocket init - no network');
    }
  }

  void _startHealthCheck() {
    _healthCheckTimer?.cancel();

    _healthCheckTimer = Timer.periodic(HEALTH_CHECK_INTERVAL, (timer) {
      if (!_shouldReconnect || !_isNetworkAvailable) {
        debugPrint(
          '[IPTV-HEALTH] ⏸️ Health check paused - no reconnect or network',
        );
        return;
      }

      final now = DateTime.now();
      final lastHeartbeat = _wsManager.lastHeartbeatReceived;
      final lastMessage = _wsManager.lastMessageReceived;

      if (lastHeartbeat != null && lastMessage != null) {
        final timeSinceLastHeartbeat = now.difference(lastHeartbeat);
        final timeSinceLastMessage = now.difference(lastMessage);

        debugPrint(
          '[IPTV-HEALTH] 🔍 Check - Connected: ${_wsManager.isConnected}, '
          'Last heartbeat: ${timeSinceLastHeartbeat.inSeconds}s, '
          'Last message: ${timeSinceLastMessage.inSeconds}s',
        );

        // Check heartbeat
        if (timeSinceLastHeartbeat > HEARTBEAT_TIMEOUT) {
          debugPrint('[IPTV-HEALTH] ❌ Heartbeat timeout - reconnecting');
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
            debugPrint(
              '[IPTV-HEALTH] 🔄 MESSAGE_TIMEOUT reached - refreshing data',
            );
            refreshTickerData();
          }
        }
      }
    });
  }

  void _startDataRefreshTimer() {
    _dataRefreshTimer?.cancel();

    _dataRefreshTimer = Timer.periodic(DATA_REFRESH_INTERVAL, (timer) async {
      if (_isNetworkAvailable &&
          state.tickerStatus != TickerStatus.loading &&
          state.tickerStatus == TickerStatus.success) {
        debugPrint('[IPTV-TIMER] 🔄 Periodic data refresh');
        await refreshTickerData();
      } else {
        debugPrint(
          '[IPTV-TIMER] ⏸️ Skipping refresh - no network or already loading',
        );
      }
    });
  }

  void _handleTvUpdate() {
    debugPrint('[IPTV-WS] 📺 TV update received - refreshing ticker data');

    // Refresh ticker data when TV update is received
    if (state.tickerStatus != TickerStatus.loading && _isNetworkAvailable) {
      refreshTickerData();
    }
  }

  Future<void> fetchTickerData() async {
    if (!_isNetworkAvailable) {
      debugPrint('[IPTV-API] ❌ Skipping data load - no network');
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

    await _fetchTickerDataWithRetry();
  }

  Future<void> _fetchTickerDataWithRetry() async {
    if (!_isNetworkAvailable) {
      debugPrint('[IPTV-API] ❌ Skipping data load - no network');
      emit(
        state.copyWith(
          tickerStatus: TickerStatus.error,
          errorMessage: 'No internet connection',
        ),
      );
      return;
    }

    try {
      final response = await _apiClient.getApi(ApiConstants.tickers);

      if (response != null && response.statusCode == 200) {
        final tickerModel = TickerModel.fromJson(response.data);

        _apiRetryAttempts = 0; // Reset on success

        emit(
          state.copyWith(
            tickerStatus: TickerStatus.success,
            tickerData: tickerModel.data,
            errorMessage: null,
          ),
        );

        debugPrint('[IPTV-API] ✅ Ticker data loaded successfully');
      } else {
        throw Exception('Failed to load ticker data');
      }
    } catch (e, stack) {
      debugPrint('[IPTV-API] ❌ Failed to load ticker data: $e');
      debugPrint(stack.toString());

      _apiRetryAttempts++;

      if (_apiRetryAttempts < MAX_API_RETRY_ATTEMPTS) {
        final delay = Duration(seconds: (3 * _apiRetryAttempts).clamp(3, 30));
        debugPrint(
          '[IPTV-API] 🔄 Retry attempt $_apiRetryAttempts in ${delay.inSeconds}s',
        );

        await Future.delayed(delay);
        if (_shouldReconnect && !isClosed) {
          await _fetchTickerDataWithRetry();
        }
      } else {
        emit(
          state.copyWith(
            tickerStatus: TickerStatus.error,
            errorMessage:
                'Failed to load data after $_apiRetryAttempts attempts',
          ),
        );
      }
    }
  }

  Future<void> refreshTickerData() async {
    if (!_isNetworkAvailable) {
      debugPrint('[IPTV-REFRESH] ⏸️ Skipping refresh - no network');
      return;
    }

    if (state.tickerStatus == TickerStatus.loading) {
      debugPrint('[IPTV-REFRESH] ⏸️ Already loading');
      return;
    }

    try {
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

        debugPrint('✅ Ticker data refreshed successfully');
      }
    } catch (e, stack) {
      debugPrint('⚠️ Refresh error: $e');
      debugPrint(stack.toString());

      // Keep current state on error (silent failure)
      // Don't emit error state during refresh to avoid flickering
    }
  }

  Future<void> onAppResumed() async {
    debugPrint('[IPTV-APP] 📱 App resumed');

    // Check network first
    await _checkInitialConnectivity();

    if (state.tickerStatus == TickerStatus.success) {
      // Refresh data
      await refreshTickerData();

      // Reconnect WebSocket if needed
      if (!_wsManager.isConnected &&
          _isNetworkAvailable &&
          _currentTvId != null) {
        await _wsManager.reconnect();
      }
    }
  }

  Future<void> manualRetry() async {
    debugPrint('[IPTV-MANUAL] 🔄 Manual retry requested');

    // Reset attempts
    _apiRetryAttempts = 0;
    _wsManager.resetAttempts();

    // Cancel existing timers
    _networkRetryTimer?.cancel();

    // Check network
    await _checkInitialConnectivity();

    // Refresh everything
    if (state.tickerStatus == TickerStatus.success) {
      await refreshTickerData();

      if (_isNetworkAvailable && _currentTvId != null) {
        await _wsManager.reconnect();
      }
    } else {
      // Try to reload from scratch
      await fetchTickerData();
    }
  }

  @override
  Future<void> close() {
    _shouldReconnect = false;

    // Cancel all timers
    _healthCheckTimer?.cancel();
    _dataRefreshTimer?.cancel();
    _networkRetryTimer?.cancel();
    _connectivitySubscription.cancel();

    // Clean up WebSocket
    _wsManager.dispose();

    return super.close();
  }
}
