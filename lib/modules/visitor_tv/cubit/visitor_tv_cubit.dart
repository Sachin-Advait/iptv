// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/models/display_token.dart';
import 'package:oman_tv/modules/visitor_tv/pages/components/helper.dart';
import 'package:oman_tv/modules/visitor_tv/repo/visitor_tv_repo.dart';
import 'package:oman_tv/services/google_speech.dart';
import 'package:oman_tv/services/web_socket_service.dart';

part 'visitor_tv_state.dart';

class VisitorTvCubit extends Cubit<VisitorTvState> {
  final VisitorTvRepo tvDisplayRepository;
  final AudioPlayer _player = AudioPlayer();
  final PiperTtsService tts;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final WebSocketService _wsManager = WebSocketService();

  Timer? _healthCheckTimer;
  Timer? _dataRefreshTimer;
  Timer? _networkRetryTimer;

  String? _currentBranchId;
  int _apiRetryAttempts = 0;
  bool _shouldReconnect = true;
  bool _isNetworkAvailable = true;

  // Configuration for Kiosk mode
  static const int MAX_API_RETRY_ATTEMPTS = 10;
  static const Duration HEALTH_CHECK_INTERVAL = Duration(seconds: 30);
  static const Duration HEARTBEAT_TIMEOUT = Duration(seconds: 150);
  static const Duration MESSAGE_TIMEOUT = Duration(minutes: 5);
  static const Duration DATA_REFRESH_INTERVAL = Duration(minutes: 5);
  static const Duration NETWORK_RETRY_INTERVAL = Duration(seconds: 10);

  VisitorTvCubit(this.tvDisplayRepository, this.tts)
    : super(TVDisplayInitial()) {
    _initializeConnectivityListener();
    _setupWebSocketCallbacks();
  }

  void _setupWebSocketCallbacks() {
    _wsManager.onDisplayDataReceived = _handleWebSocketUpdate;
    _wsManager.onConnectionSuccess = () async {
      if (state is TVDisplayLoaded) {
        emit(
          (state as TVDisplayLoaded).copyWith(
            errorMessage: null,
            wasNetworkRestored: false,
          ),
        );
      }
      // Refresh data after successful connection
      await refreshData(_currentBranchId!);
    };
    _wsManager.onConnectionError = (error) {
      if (state is TVDisplayLoaded) {
        emit((state as TVDisplayLoaded).copyWith(errorMessage: error));
      }
    };
  }

  void _initializeConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final result = results.isNotEmpty
          ? results.last
          : ConnectivityResult.none;
      _handleConnectivityChange(result);
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
      _handleConnectivityChange(result);
    } catch (e) {
      debugPrint('[TV-NETWORK] Error checking initial connectivity: $e');
    }
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    final isConnected = result != ConnectivityResult.none;
    final previouslyConnected = _isNetworkAvailable;

    _isNetworkAvailable = isConnected;
    _wsManager.updateNetworkStatus(isConnected);

    if (state is TVDisplayLoaded) {
      emit(
        (state as TVDisplayLoaded).copyWith(
          isNetworkConnected: isConnected,
          connectivityStatus: result,
        ),
      );
    }

    // Handle network state changes
    if (isConnected && !previouslyConnected) {
      debugPrint('[TV-NETWORK] ✅ Network connection restored');

      // Cancel any network retry timer
      _networkRetryTimer?.cancel();
      _networkRetryTimer = null;

      if (state is TVDisplayLoaded) {
        emit(
          (state as TVDisplayLoaded).copyWith(
            wasNetworkRestored: true,
            errorMessage: null,
          ),
        );
      }

      // Reset retry attempts when network comes back
      _apiRetryAttempts = 0;
      _wsManager.resetAttempts();

      // Auto-reconnect WebSocket
      if (!_wsManager.isConnected && _currentBranchId != null) {
        debugPrint(
          '[TV-NETWORK] 🔄 Auto-reconnecting WebSocket after network restore',
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (_isNetworkAvailable) {
            _wsManager.reconnect();
          }
        });
      }

      // Refresh data when network comes back
      if (_currentBranchId != null) {
        Future.delayed(const Duration(seconds: 3), () {
          if (_isNetworkAvailable) {
            refreshData(_currentBranchId!);
          }
        });
      }
    } else if (!isConnected && previouslyConnected) {
      debugPrint('[TV-NETWORK] ❌ Network connection lost');

      if (state is TVDisplayLoaded) {
        emit(
          (state as TVDisplayLoaded).copyWith(
            wasNetworkRestored: false,
            errorMessage: 'No internet connection',
          ),
        );
      } else {
        emit(TVDisplayError('No internet connection', isNetworkError: true));
      }

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
          debugPrint('[TV-NETWORK] ✅ Network detected during retry check');
          timer.cancel();
          _handleConnectivityChange(result);
        } else {
          debugPrint('[TV-NETWORK] 🔄 Still waiting for network...');
        }
      } catch (e) {
        debugPrint('[TV-NETWORK] ❌ Error checking network: $e');
      }
    });
  }

  Future<void> loadDisplayData(String branchId) async {
    _currentBranchId = branchId;
    _shouldReconnect = true;
    emit(TVDisplayLoading());

    await _loadDisplayDataWithRetry(branchId);
  }

  Future<void> _loadDisplayDataWithRetry(String branchId) async {
    if (!_isNetworkAvailable) {
      debugPrint('[TV-API] ❌ Skipping data load - no network');
      emit(TVDisplayError('No internet connection', isNetworkError: true));
      return;
    }

    try {
      final displayData = await tvDisplayRepository.getDisplayData(branchId);

      _apiRetryAttempts = 0; // Reset on success

      emit(
        TVDisplayLoaded(
          latestCalls: displayData.latestCalls,
          nowServing: displayData.nowServing,
          upcomingTokens: displayData.upcomingTokens,
          holdTokens: displayData.holdTokens,
          isNetworkConnected: _isNetworkAvailable,
          connectivityStatus: _isNetworkAvailable
              ? ConnectivityResult.wifi
              : ConnectivityResult.none,
        ),
      );

      // Start WebSocket and periodic tasks
      _startDataRefreshTimer();
      await _wsManager.connect(branchId);
      _startHealthCheck();
    } catch (e) {
      debugPrint('[TV-API] ❌ Failed to load display data: $e');

      _apiRetryAttempts++;

      if (_apiRetryAttempts < MAX_API_RETRY_ATTEMPTS) {
        final delay = Duration(seconds: (3 * _apiRetryAttempts).clamp(3, 30));
        debugPrint(
          '[TV-API] 🔄 Retry attempt $_apiRetryAttempts in ${delay.inSeconds}s',
        );

        Future.delayed(delay, () {
          if (_shouldReconnect && state is! TVDisplayLoading) {
            _loadDisplayDataWithRetry(branchId);
          }
        });
      } else {
        emit(
          TVDisplayError(
            'Failed to load data after $_apiRetryAttempts attempts',
          ),
        );

        // Still try to connect WebSocket for real-time updates
        if (_currentBranchId != null) {
          _wsManager.connect(branchId);
        }
      }
    }
  }

  void _startDataRefreshTimer() {
    _dataRefreshTimer?.cancel();

    _dataRefreshTimer = Timer.periodic(DATA_REFRESH_INTERVAL, (timer) async {
      if (_isNetworkAvailable &&
          state is! TVDisplayLoading &&
          _currentBranchId != null) {
        debugPrint('[TV-TIMER] 🔄 Periodic data refresh');
        await refreshData(_currentBranchId!);
      } else {
        debugPrint(
          '[TV-TIMER] ⏸️ Skipping refresh - no network or already loading',
        );
      }
    });
  }

  void _startHealthCheck() {
    _healthCheckTimer?.cancel();

    _healthCheckTimer = Timer.periodic(HEALTH_CHECK_INTERVAL, (timer) {
      if (!_shouldReconnect || !_isNetworkAvailable) {
        debugPrint(
          '[TV-HEALTH] ⏸️ Health check paused - no reconnect or network',
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
          '[TV-HEALTH] 🔍 Check - Connected: ${_wsManager.isConnected}, '
          'Last heartbeat: ${timeSinceLastHeartbeat.inSeconds}s, '
          'Last message: ${timeSinceLastMessage.inSeconds}s',
        );

        // Check heartbeat
        if (timeSinceLastHeartbeat > HEARTBEAT_TIMEOUT) {
          debugPrint('[TV-HEALTH] ❌ Heartbeat timeout - reconnecting');
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
              _currentBranchId != null) {
            debugPrint(
              '[TV-HEALTH] 🔄 MESSAGE_TIMEOUT reached - refreshing data',
            );
            refreshData(_currentBranchId!);
          }
        }
      }
    });
  }

  Future<void> refreshData(String branchId) async {
    if (!_isNetworkAvailable) {
      debugPrint('[TV-REFRESH] ⏸️ Skipping refresh - no network');
      return;
    }

    if (state is TVDisplayLoading) {
      debugPrint('[TV-REFRESH] ⏸️ Already loading');
      return;
    }

    try {
      final displayData = await tvDisplayRepository.getDisplayData(branchId);

      _updateDisplayData(displayData: displayData);
    } catch (e) {
      debugPrint('[TV-REFRESH] ❌ Data refresh failed: $e');
    }
  }

  void _handleWebSocketUpdate(String frameBody) {
    try {
      final jsonData = jsonDecode(frameBody);
      final displayData = TVDisplayResponse.fromJson(jsonData);

      debugPrint('[TV-WS] ✅ Parsed display data from WebSocket');

      _updateDisplayData(displayData: displayData);
    } catch (e) {
      debugPrint('[TV-WS] ❌ Failed to parse display data: $e');
    }
  }

  void _updateDisplayData({required TVDisplayResponse displayData}) {
    // Check if there are new calls to announce
    bool shouldPlaySound = false;
    DisplayToken? tokenToAnnounce;

    if (state is TVDisplayLoaded) {
      final currentState = state as TVDisplayLoaded;
      final currentTokens = currentState.latestCalls
          .map((t) => '${t.token}-${t.counter}')
          .toSet();
      final newTokens = displayData.latestCalls
          .map((t) => '${t.token}-${t.counter}')
          .toSet();

      final newTokenSet = newTokens.difference(currentTokens);
      shouldPlaySound = newTokenSet.isNotEmpty;

      if (shouldPlaySound && displayData.latestCalls.isNotEmpty) {
        tokenToAnnounce = displayData.latestCalls.firstWhere(
          (token) => newTokenSet.contains('${token.token}-${token.counter}'),
          orElse: () => displayData.latestCalls.first,
        );
      }
    } else {
      shouldPlaySound = displayData.latestCalls.isNotEmpty;
      if (shouldPlaySound) {
        tokenToAnnounce = displayData.latestCalls.first;
      }
    }

    // Update state
    emit(
      TVDisplayLoaded(
        latestCalls: displayData.latestCalls,
        nowServing: displayData.nowServing,
        upcomingTokens: displayData.upcomingTokens,
        holdTokens: displayData.holdTokens,
        isNetworkConnected: _isNetworkAvailable,
        connectivityStatus: state is TVDisplayLoaded
            ? (state as TVDisplayLoaded).connectivityStatus
            : ConnectivityResult.none,
      ),
    );

    // Play announcement if needed
    if (shouldPlaySound && tokenToAnnounce != null) {
      Helper.playAnnouncement(tokenToAnnounce, _player, tts);
    }
  }

  Future<void> onAppResumed() async {
    debugPrint('[TV-APP] 📱 App resumed');

    // Check network first
    await _checkInitialConnectivity();

    if (_currentBranchId != null) {
      // Refresh data
      await refreshData(_currentBranchId!);

      // Reconnect WebSocket if needed
      if (!_wsManager.isConnected && _isNetworkAvailable) {
        await _wsManager.reconnect();
      }
    }
  }

  Future<void> manualRetry() async {
    debugPrint('[TV-MANUAL] 🔄 Manual retry requested');

    // Reset attempts
    _apiRetryAttempts = 0;
    _wsManager.resetAttempts();

    // Cancel existing timers
    _networkRetryTimer?.cancel();

    // Check network
    await _checkInitialConnectivity();

    // Refresh everything
    if (_currentBranchId != null) {
      await refreshData(_currentBranchId!);

      if (_isNetworkAvailable) {
        await _wsManager.reconnect();
      }
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

    // Clean up WebSocket and audio
    _wsManager.dispose();
    _player.dispose();

    return super.close();
  }
}
