// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/models/tv_display_response.dart';
import 'package:oman_tv/modules/meeting_tv/repository/meeting_tv_repo.dart';
import 'package:oman_tv/services/tv_display_web_socket.dart';

part 'tv_display_event.dart';
part 'tv_display_state.dart';

class MeetingTvBloc extends Bloc<TvDisplayEvent, TvDisplayState> {
  final MeetingTvRepo meetingTvRepo;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final TvDisplayWebSocketService _wsManager = TvDisplayWebSocketService();

  Timer? _healthCheckTimer;
  Timer? _dataRefreshTimer;
  Timer? _networkRetryTimer;

  int _apiRetryAttempts = 0;
  bool _shouldReconnect = true;
  bool _isNetworkAvailable = true;
  bool _hasLoadedOnce = false;

  // Configuration
  static const int MAX_API_RETRY_ATTEMPTS = 10;
  static const Duration HEALTH_CHECK_INTERVAL = Duration(seconds: 30);
  static const Duration HEARTBEAT_TIMEOUT = Duration(seconds: 150);
  static const Duration NETWORK_RETRY_INTERVAL = Duration(seconds: 10);
  static const Duration MESSAGE_TIMEOUT = Duration(minutes: 5);
  static const Duration DATA_REFRESH_INTERVAL = Duration(minutes: 2);

  MeetingTvBloc({required this.meetingTvRepo}) : super(TvDisplayInitial()) {
    on<LoadTvDisplayData>(_onLoadTvDisplayData);
    on<RefreshTvDisplayData>(_onRefreshTvDisplayData);
    on<UpdateTvDisplayFromSocketEvent>(_onUpdateTvDisplayFromSocket);
    on<NetworkConnectivityChangedEvent>(_onNetworkConnectivityChanged);
    on<UpdateConnectionStatusEvent>(_onUpdateConnectionStatus);
    on<OnAppResumedEvent>(_onAppResumed);
    on<ManualRetryEvent>(_onManualRetry);

    _initializeConnectivityListener();
    _setupWebSocketCallbacks();
  }

  // ---------------------------------------------------------------------------
  // Setup
  // ---------------------------------------------------------------------------

  void _setupWebSocketCallbacks() {
    _wsManager.onDisplayDataReceived = (displayData) {
      add(UpdateTvDisplayFromSocketEvent(displayData));
    };

    _wsManager.onConnectionSuccess = () {
      if (state is TvDisplayLoaded) {
        add(const UpdateConnectionStatusEvent(isNetworkConnected: true));
      }
      // Refresh data after successful (re)connection
      add(RefreshTvDisplayData());
    };

    _wsManager.onConnectionError = (error) {
      debugPrint('[TV-BLOC] ⚠️ WS connection error: $error');
    };
  }

  void _initializeConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final result = results.isNotEmpty
          ? results.last
          : ConnectivityResult.none;
      add(NetworkConnectivityChangedEvent(result));
    });

    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final result = results.isNotEmpty
          ? results.last
          : ConnectivityResult.none;
      add(NetworkConnectivityChangedEvent(result));
    } catch (e) {
      debugPrint('[TV-NETWORK] Error checking initial connectivity: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Network connectivity
  // ---------------------------------------------------------------------------

  Future<void> _onNetworkConnectivityChanged(
    NetworkConnectivityChangedEvent event,
    Emitter<TvDisplayState> emit,
  ) async {
    final isConnected = event.result != ConnectivityResult.none;
    final previouslyConnected = _isNetworkAvailable;

    _isNetworkAvailable = isConnected;
    _wsManager.updateNetworkStatus(isConnected);

    // Update network flag in current state if loaded
    if (state is TvDisplayLoaded) {
      emit(
        (state as TvDisplayLoaded).copyWith(isNetworkConnected: isConnected),
      );
    }

    if (isConnected && !previouslyConnected) {
      debugPrint('[TV-NETWORK] ✅ Network restored');
      _networkRetryTimer?.cancel();
      _networkRetryTimer = null;

      _apiRetryAttempts = 0;
      _wsManager.resetAttempts();

      // Auto-reconnect WebSocket
      if (!_wsManager.isConnected) {
        Future.delayed(const Duration(seconds: 2), () {
          if (_isNetworkAvailable) _wsManager.reconnect();
        });
      }

      // Refresh data
      Future.delayed(const Duration(seconds: 3), () {
        if (_isNetworkAvailable) {
          if (!_hasLoadedOnce) {
            add(LoadTvDisplayData());
          } else {
            add(RefreshTvDisplayData());
          }
        }
      });
    } else if (!isConnected && previouslyConnected) {
      debugPrint('[TV-NETWORK] ❌ Network lost');

      if (state is TvDisplayLoaded) {
        emit((state as TvDisplayLoaded).copyWith(isNetworkConnected: false));
      } else if (state is! TvDisplayError) {
        emit(
          const TvDisplayError(
            message: 'No internet connection',
            isNetworkError: true,
          ),
        );
      }

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
          timer.cancel();
          add(NetworkConnectivityChangedEvent(result));
        } else {
          debugPrint('[TV-NETWORK] 🔄 Still waiting for network...');
        }
      } catch (e) {
        debugPrint('[TV-NETWORK] ❌ Error checking network: $e');
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Load (initial, with retry)
  // ---------------------------------------------------------------------------

  Future<void> _onLoadTvDisplayData(
    LoadTvDisplayData event,
    Emitter<TvDisplayState> emit,
  ) async {
    _shouldReconnect = true;
    emit(TvDisplayLoading());
    await _loadWithRetry(emit);
  }

  Future<void> _loadWithRetry(Emitter<TvDisplayState> emit) async {
    if (!_isNetworkAvailable) {
      debugPrint('[TV-API] ❌ Skipping load — no network');
      emit(
        const TvDisplayError(
          message: 'No internet connection',
          isNetworkError: true,
        ),
      );
      return;
    }

    try {
      final response = await meetingTvRepo.getTvDisplayData();

      if (response.status == true && response.data != null) {
        _apiRetryAttempts = 0;

        emit(
          TvDisplayLoaded(
            tvDisplayDetails: response.data!,
            isNetworkConnected: _isNetworkAvailable,
          ),
        );

        debugPrint('[TV-API] ✅ TV Display data loaded successfully');

        if (!_hasLoadedOnce) {
          _hasLoadedOnce = true;
          await _wsManager.connect();
          _startDataRefreshTimer();
          _startHealthCheck();
        }
      } else {
        throw Exception(response.message ?? 'Failed to load data');
      }
    } catch (e, stack) {
      debugPrint('[TV-API] ❌ Load failed: $e');
      debugPrint(stack.toString());

      _apiRetryAttempts++;

      if (_apiRetryAttempts < MAX_API_RETRY_ATTEMPTS) {
        final delay = Duration(seconds: (3 * _apiRetryAttempts).clamp(3, 30));
        debugPrint(
          '[TV-API] 🔄 Retry attempt $_apiRetryAttempts in ${delay.inSeconds}s',
        );
        await Future.delayed(delay);
        if (_shouldReconnect && !emit.isDone) {
          await _loadWithRetry(emit);
        }
      } else {
        if (!emit.isDone) {
          emit(
            TvDisplayError(
              message: 'Failed to load data after $_apiRetryAttempts attempts',
            ),
          );
        }
        // Still try WS even after API failure
        _wsManager.connect();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Refresh (silent background)
  // ---------------------------------------------------------------------------

  Future<void> _onRefreshTvDisplayData(
    RefreshTvDisplayData event,
    Emitter<TvDisplayState> emit,
  ) async {
    if (!_isNetworkAvailable) {
      debugPrint('[TV-REFRESH] ⏸️ No network — skipping');
      return;
    }

    if (state is TvDisplayLoading) {
      debugPrint('[TV-REFRESH] ⏸️ Already loading');
      return;
    }

    debugPrint('[TV-REFRESH] 🔄 Silent refresh');

    try {
      final response = await meetingTvRepo.getTvDisplayData();

      if (response.status == true && response.data != null) {
        emit(
          TvDisplayLoaded(
            tvDisplayDetails: response.data!,
            isNetworkConnected: _isNetworkAvailable,
          ),
        );
        debugPrint('[TV-REFRESH] ✅ Refreshed successfully');
      } else {
        // Silent failure — keep existing state
        debugPrint(
          '[TV-REFRESH] ⚠️ Refresh failed: ${response.message}, keeping state',
        );
      }
    } catch (e) {
      debugPrint('[TV-REFRESH] ⚠️ Refresh exception (silent): $e');
    }
  }

  // ---------------------------------------------------------------------------
  // WebSocket update
  // ---------------------------------------------------------------------------

  void _onUpdateTvDisplayFromSocket(
    UpdateTvDisplayFromSocketEvent event,
    Emitter<TvDisplayState> emit,
  ) {
    try {
      final TvDisplayDetails updatedDetails = TvDisplayDetails.fromJson(
        event.displayData,
      );

      if (state is TvDisplayLoaded) {
        emit(
          (state as TvDisplayLoaded).copyWith(tvDisplayDetails: updatedDetails),
        );
        debugPrint('[TV-WS] ✅ TV Display updated from WebSocket');
      }
    } catch (e) {
      debugPrint('[TV-WS] ❌ Error updating from socket: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Timers
  // ---------------------------------------------------------------------------

  void _startDataRefreshTimer() {
    _dataRefreshTimer?.cancel();

    _dataRefreshTimer = Timer.periodic(DATA_REFRESH_INTERVAL, (_) {
      if (_isNetworkAvailable && state is! TvDisplayLoading) {
        debugPrint('[TV-TIMER] 🔄 Periodic data refresh');
        add(RefreshTvDisplayData());
      } else {
        debugPrint('[TV-TIMER] ⏸️ Skipping — no network or loading');
      }
    });
  }

  void _startHealthCheck() {
    _healthCheckTimer?.cancel();

    _healthCheckTimer = Timer.periodic(HEALTH_CHECK_INTERVAL, (_) {
      if (!_shouldReconnect || !_isNetworkAvailable) {
        debugPrint('[TV-HEALTH] ⏸️ Paused');
        return;
      }

      final now = DateTime.now();
      final lastHeartbeat = _wsManager.lastHeartbeatReceived;
      final lastMessage = _wsManager.lastMessageReceived;

      if (lastHeartbeat != null && lastMessage != null) {
        final sinceHeartbeat = now.difference(lastHeartbeat);
        final sinceMessage = now.difference(lastMessage);

        debugPrint(
          '[TV-HEALTH] 🔍 WS connected: ${_wsManager.isConnected} | '
          'heartbeat: ${sinceHeartbeat.inSeconds}s | '
          'message: ${sinceMessage.inSeconds}s',
        );

        // Heartbeat timeout → reconnect
        if (sinceHeartbeat > HEARTBEAT_TIMEOUT) {
          debugPrint('[TV-HEALTH] ❌ Heartbeat timeout — reconnecting');
          _wsManager.reconnect();
          return;
        }

        // Message timeout → single data refresh (first interval after timeout)
        if (sinceMessage > MESSAGE_TIMEOUT && _wsManager.isConnected) {
          final intervalsSinceMessage =
              sinceMessage.inSeconds ~/ HEALTH_CHECK_INTERVAL.inSeconds;
          final intervalsAtTimeout =
              MESSAGE_TIMEOUT.inSeconds ~/ HEALTH_CHECK_INTERVAL.inSeconds;

          if (intervalsSinceMessage == intervalsAtTimeout) {
            debugPrint('[TV-HEALTH] 🔄 MESSAGE_TIMEOUT — refreshing data');
            add(RefreshTvDisplayData());
          }
        }
      }
    });
  }

  // ---------------------------------------------------------------------------
  // App lifecycle & manual retry
  // ---------------------------------------------------------------------------

  Future<void> _onAppResumed(
    OnAppResumedEvent event,
    Emitter<TvDisplayState> emit,
  ) async {
    debugPrint('[TV-APP] 📱 App resumed');
    await _checkInitialConnectivity();

    add(RefreshTvDisplayData());

    if (!_wsManager.isConnected && _isNetworkAvailable) {
      await _wsManager.reconnect();
    }
  }

  Future<void> _onManualRetry(
    ManualRetryEvent event,
    Emitter<TvDisplayState> emit,
  ) async {
    debugPrint('[TV-MANUAL] 🔄 Manual retry');

    _apiRetryAttempts = 0;
    _wsManager.resetAttempts();
    _networkRetryTimer?.cancel();

    await _checkInitialConnectivity();

    if (_hasLoadedOnce) {
      add(RefreshTvDisplayData());
      if (_isNetworkAvailable) await _wsManager.reconnect();
    } else {
      add(LoadTvDisplayData());
    }
  }

  Future<void> _onUpdateConnectionStatus(
    UpdateConnectionStatusEvent event,
    Emitter<TvDisplayState> emit,
  ) async {
    if (state is TvDisplayLoaded) {
      emit(
        (state as TvDisplayLoaded).copyWith(
          isNetworkConnected: event.isNetworkConnected,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  @override
  Future<void> close() {
    _shouldReconnect = false;

    _healthCheckTimer?.cancel();
    _dataRefreshTimer?.cancel();
    _networkRetryTimer?.cancel();
    _connectivitySubscription.cancel();

    _wsManager.dispose();

    return super.close();
  }
}
