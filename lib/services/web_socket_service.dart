// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  StompClient? _stompClient;
  Timer? _reconnectionTimer;
  Timer? _connectionTimeoutTimer;

  DateTime? _lastMessageReceived;
  DateTime? _lastHeartbeatReceived;
  int _reconnectAttempts = 0;
  bool _isWebSocketConnected = false;
  bool _isConnecting = false;
  bool _shouldReconnect = true;
  bool _isNetworkAvailable = true;

  // Configuration for Kiosk mode
  static const int MAX_RECONNECT_ATTEMPTS = 20;
  static const Duration CONNECTION_TIMEOUT = Duration(seconds: 15);

  String? _currentBranchId;

  // Callbacks
  Function(String)? onDisplayDataReceived;
  Function()? onConnectionSuccess;
  Function(String)? onConnectionError;

  bool get isConnected => _isWebSocketConnected;
  DateTime? get lastMessageReceived => _lastMessageReceived;
  DateTime? get lastHeartbeatReceived => _lastHeartbeatReceived;

  void updateNetworkStatus(bool isAvailable) {
    _isNetworkAvailable = isAvailable;
  }

  Future<void> connect(String branchId) async {
    if (_isConnecting || !_isNetworkAvailable) {
      debugPrint('[TV-WS] ⏸️ Already connecting or no network');
      return;
    }

    _currentBranchId = branchId;
    _isConnecting = true;
    _reconnectionTimer?.cancel();
    _connectionTimeoutTimer?.cancel();

    _connectionTimeoutTimer = Timer(CONNECTION_TIMEOUT, () {
      if (_isConnecting) {
        debugPrint('[TV-WS] ⏱️ Connection timeout');
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
        debugPrint('[TV-WS] ⚠️ Error during deactivation: $e');
      }
      _stompClient = null;
    }

    debugPrint(
      '[TV-WS] 🔌 Connecting to wss://serveiqbackend.insyncproducts.online/serveiq/ws for branch: $branchId',
    );

    _stompClient = StompClient(
      config: StompConfig(
        url: "wss://serveiqbackend.insyncproducts.online/serveiq/ws",
        onConnect: (StompFrame frame) async {
          _connectionTimeoutTimer?.cancel();
          _isConnecting = false;
          _isWebSocketConnected = true;
          _lastMessageReceived = DateTime.now();
          _lastHeartbeatReceived = DateTime.now();
          _reconnectAttempts = 0;

          debugPrint('[TV-WS] ✅ Connected for branch: $branchId');

          onConnectionSuccess?.call();

          // Subscribe to branch-specific topic
          _stompClient?.subscribe(
            destination: '/topic/tv/$branchId',
            callback: (StompFrame frame) {
              _lastMessageReceived = DateTime.now();
              _reconnectAttempts = 0;

              if (frame.body != null && frame.body!.isNotEmpty) {
                debugPrint('[TV-WS] 📨 Display data received');
                onDisplayDataReceived?.call(frame.body!);
              }
            },
          );

          // Subscribe to global heartbeat topic
          _stompClient?.subscribe(
            destination: '/topic/heartbeat',
            callback: (StompFrame frame) {
              _lastHeartbeatReceived = DateTime.now();
              debugPrint('[TV-WS] 💓 Heartbeat received');
            },
          );
        },
        onWebSocketError: (dynamic error) {
          _connectionTimeoutTimer?.cancel();
          _isConnecting = false;
          _isWebSocketConnected = false;
          debugPrint('[TV-WS] ❌ WebSocket error: $error');
          onConnectionError?.call('WebSocket error: $error');
          _scheduleReconnection();
        },
        onStompError: (StompFrame frame) {
          _connectionTimeoutTimer?.cancel();
          _isConnecting = false;
          _isWebSocketConnected = false;
          debugPrint('[TV-WS] ❌ STOMP error: ${frame.body}');
          onConnectionError?.call('STOMP error: ${frame.body}');
          _scheduleReconnection();
        },
        onDisconnect: (StompFrame frame) {
          _connectionTimeoutTimer?.cancel();
          _isConnecting = false;

          if (_isWebSocketConnected) {
            debugPrint('[TV-WS] ⚠️ Disconnected unexpectedly');
            _isWebSocketConnected = false;
            _scheduleReconnection();
          }
        },
        beforeConnect: () async {
          debugPrint('[TV-WS] 🔗 Attempting connection...');
        },
        stompConnectHeaders: {},
        webSocketConnectHeaders: {},
        heartbeatIncoming: const Duration(seconds: 60),
        heartbeatOutgoing: const Duration(seconds: 60),
        reconnectDelay: Duration.zero,
      ),
    );

    try {
      _stompClient?.activate();
    } catch (e) {
      debugPrint('[TV-WS] ❌ Failed to activate STOMP: $e');
      _isConnecting = false;
      onConnectionError?.call('Failed to activate: $e');
      _scheduleReconnection();
    }
  }

  Future<void> reconnect() async {
    if (!_isNetworkAvailable) {
      debugPrint('[TV-WS] ⏸️ Cannot reconnect - no network');
      return;
    }

    debugPrint('[TV-WS] 🔄 Forcing WebSocket reconnection');
    _isWebSocketConnected = false;
    _isConnecting = false;

    if (_currentBranchId != null) {
      await connect(_currentBranchId!);
    }
  }

  void _scheduleReconnection() {
    if (!_shouldReconnect || _isConnecting || !_isNetworkAvailable) {
      debugPrint('[TV-WS] ⏸️ Skipping reconnection schedule');
      return;
    }

    if (_reconnectAttempts >= MAX_RECONNECT_ATTEMPTS) {
      debugPrint('[TV-WS] ⛔ Max reconnection attempts reached');
      // Reset attempts after a longer delay for kiosk mode
      Future.delayed(const Duration(minutes: 5), () {
        _reconnectAttempts = 0;
        if (_shouldReconnect && _isNetworkAvailable) {
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
      '[TV-WS] ⏰ Scheduling reconnection attempt $_reconnectAttempts in ${delay.inSeconds}s',
    );

    _reconnectionTimer?.cancel();
    _reconnectionTimer = Timer(delay, () async {
      if (_shouldReconnect &&
          !_isConnecting &&
          _isNetworkAvailable &&
          _currentBranchId != null) {
        await connect(_currentBranchId!);
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
    _stompClient?.deactivate();
    _stompClient = null;
  }
}
