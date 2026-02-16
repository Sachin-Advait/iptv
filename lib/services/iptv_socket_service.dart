// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oman_tv/common/constants/api_constants.dart';
import 'package:oman_tv/common/utils/get_it.dart';
import 'package:oman_tv/services/connectivity_service.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class IptvSocketService {
  StompClient? _stompClient;
  Timer? _reconnectionTimer;
  Timer? _connectionTimeoutTimer;
  StreamSubscription<bool>? _connectivitySubscription;

  final ConnectivityService _connectivityService = getIt<ConnectivityService>();

  DateTime? _lastMessageReceived;
  DateTime? _lastHeartbeatReceived;
  int _reconnectAttempts = 0;
  bool _isWebSocketConnected = false;
  bool _isConnecting = false;
  bool _shouldReconnect = true;

  // Configuration
  static const int MAX_RECONNECT_ATTEMPTS = 20;
  static const Duration CONNECTION_TIMEOUT = Duration(seconds: 15);

  String? _currentTvId;

  // Callbacks
  Function()? onTvUpdateReceived;
  Function()? onConnectionSuccess;
  Function(String)? onConnectionError;

  bool get isConnected => _isWebSocketConnected;
  DateTime? get lastMessageReceived => _lastMessageReceived;
  DateTime? get lastHeartbeatReceived => _lastHeartbeatReceived;

  IptvSocketService() {
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivityService.connectionStream.listen((
      isConnected,
    ) {
      if (isConnected) {
        debugPrint('[IPTV-WS] 🌐 Internet restored - auto-reconnecting');
        _reconnectAttempts = 0;
        if (!_isWebSocketConnected && _currentTvId != null) {
          Future.delayed(const Duration(seconds: 2), () {
            if (_connectivityService.isConnected) {
              reconnect();
            }
          });
        }
      } else {
        debugPrint('[IPTV-WS] 📵 Internet lost');
      }
    });
  }

  Future<void> connect(String tvId) async {
    if (_isConnecting) {
      debugPrint('[IPTV-WS] ⏸️ Already connecting');
      return;
    }

    if (!_connectivityService.isConnected) {
      debugPrint('[IPTV-WS] ⏸️ No network - skipping connection');
      return;
    }

    _currentTvId = tvId;
    _isConnecting = true;
    _reconnectionTimer?.cancel();
    _connectionTimeoutTimer?.cancel();

    _connectionTimeoutTimer = Timer(CONNECTION_TIMEOUT, () {
      if (_isConnecting) {
        debugPrint('[IPTV-WS] ⏱️ Connection timeout');
        _isConnecting = false;
        _stompClient?.deactivate();
        _stompClient = null;
        _scheduleReconnection();
      }
    });

    // Clean up existing connection
    if (_stompClient != null) {
      try {
        _stompClient?.deactivate();
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        debugPrint('[IPTV-WS] ⚠️ Error during deactivation: $e');
      }
      _stompClient = null;
    }

    debugPrint(
      '[IPTV-WS] 🔌 Connecting to ${ApiConstants.wsUrl} for TV: $tvId',
    );

    _stompClient = StompClient(
      config: StompConfig(
        url: ApiConstants.wsUrl,
        onConnect: (StompFrame frame) async {
          _connectionTimeoutTimer?.cancel();
          _isConnecting = false;
          _isWebSocketConnected = true;
          _lastMessageReceived = DateTime.now();
          _lastHeartbeatReceived = DateTime.now();
          _reconnectAttempts = 0;

          debugPrint('[IPTV-WS] ✅ Connected for TV: $tvId');

          onConnectionSuccess?.call();

          // Subscribe to TV update topic
          _stompClient?.subscribe(
            destination: '/topic/tv-layout/$tvId',
            callback: (StompFrame frame) {
              _lastMessageReceived = DateTime.now();
              _reconnectAttempts = 0;

              debugPrint('[IPTV-WS] 📺 TV update received for TV: $tvId');

              // Trigger callback when TV update is received
              onTvUpdateReceived?.call();
            },
          );

          // Subscribe to heartbeat topic (optional)
          _stompClient?.subscribe(
            destination: '/topic/heartbeat',
            callback: (StompFrame frame) {
              _lastHeartbeatReceived = DateTime.now();
              debugPrint('[IPTV-WS] 💓 Heartbeat received');
            },
          );
        },
        onWebSocketError: (dynamic error) {
          _connectionTimeoutTimer?.cancel();
          _isConnecting = false;
          _isWebSocketConnected = false;
          debugPrint('[IPTV-WS] ❌ WebSocket error: $error');
          onConnectionError?.call('WebSocket error: $error');
          _scheduleReconnection();
        },
        onStompError: (StompFrame frame) {
          _connectionTimeoutTimer?.cancel();
          _isConnecting = false;
          _isWebSocketConnected = false;
          debugPrint('[IPTV-WS] ❌ STOMP error: ${frame.body}');
          onConnectionError?.call('STOMP error: ${frame.body}');
          _scheduleReconnection();
        },
        onDisconnect: (StompFrame frame) {
          _connectionTimeoutTimer?.cancel();
          _isConnecting = false;

          if (_isWebSocketConnected) {
            debugPrint('[IPTV-WS] ⚠️ Disconnected unexpectedly');
            _isWebSocketConnected = false;
            _scheduleReconnection();
          }
        },
        beforeConnect: () async {
          debugPrint('[IPTV-WS] 🔗 Attempting connection...');
        },
        stompConnectHeaders: {},
        webSocketConnectHeaders: {},
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
        reconnectDelay: Duration.zero,
      ),
    );

    try {
      _stompClient?.activate();
    } catch (e) {
      debugPrint('[IPTV-WS] ❌ Failed to activate STOMP: $e');
      _isConnecting = false;
      onConnectionError?.call('Failed to activate: $e');
      _scheduleReconnection();
    }
  }

  Future<void> reconnect() async {
    if (!_connectivityService.isConnected) {
      debugPrint('[IPTV-WS] ⏸️ Cannot reconnect - no network');
      return;
    }

    debugPrint('[IPTV-WS] 🔄 Forcing WebSocket reconnection');
    _isWebSocketConnected = false;
    _isConnecting = false;

    if (_currentTvId != null) {
      await connect(_currentTvId!);
    }
  }

  void _scheduleReconnection() {
    if (!_shouldReconnect || _isConnecting) {
      debugPrint('[IPTV-WS] ⏸️ Skipping reconnection schedule');
      return;
    }

    if (!_connectivityService.isConnected) {
      debugPrint('[IPTV-WS] ⏸️ No network - will auto-reconnect when restored');
      return;
    }

    if (_reconnectAttempts >= MAX_RECONNECT_ATTEMPTS) {
      debugPrint('[IPTV-WS] ⛔ Max reconnection attempts reached');
      // Reset attempts after a longer delay
      Future.delayed(const Duration(minutes: 5), () {
        _reconnectAttempts = 0;
        if (_shouldReconnect && _connectivityService.isConnected) {
          _scheduleReconnection();
        }
      });
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(
      seconds: (3 * _reconnectAttempts).clamp(3, 60),
    ); // Max 1 minute

    debugPrint(
      '[IPTV-WS] ⏰ Scheduling reconnection attempt $_reconnectAttempts in ${delay.inSeconds}s',
    );

    _reconnectionTimer?.cancel();
    _reconnectionTimer = Timer(delay, () async {
      if (_shouldReconnect &&
          !_isConnecting &&
          _connectivityService.isConnected &&
          _currentTvId != null) {
        await connect(_currentTvId!);
      }
    });
  }

  void resetAttempts() {
    _reconnectAttempts = 0;
  }

  void dispose() {
    _shouldReconnect = false;
    _reconnectionTimer?.cancel();
    _connectionTimeoutTimer?.cancel();
    _connectivitySubscription?.cancel();
    _stompClient?.deactivate();
    _stompClient = null;
  }
}
