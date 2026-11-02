// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oman_tv/common/constants/api_constants.dart';
import 'package:oman_tv/common/utils/get_it.dart';
import 'package:oman_tv/services/connectivity_service.dart';
import 'package:oman_tv/services/tv_notification_controller.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// Keeps one STOMP connection to the IPTV backend alive for a TV.
///
/// Same approach as the ServeIQ TV socket, plus the gaps closed:
/// - STOMP heartbeats both ways (10s, the backend broker matches), so a dead
///   socket is dropped by the client within ~20s.
/// - An app-level `/topic/heartbeat` (backend sends every 60s) as a second
///   liveness signal; the watchdog forces a reconnect if it goes quiet.
/// - An abrupt drop (server restart, Wi-Fi loss, heartbeat timeout) only
///   fires `onWebSocketDone` in stomp_dart_client, never `onDisconnect`, so
///   that is handled here and schedules a reconnect.
/// - Callbacks from an old, replaced client are ignored, so a late close of
///   the previous socket cannot knock down the new connection.
/// - A watchdog reconnects whenever the socket is down and nothing is
///   scheduled, including when the TV booted before the network was up.
/// - Linear backoff (3s, 6s, ... capped at 60s); after 20 straight failures
///   it rests 5 minutes, then starts over. Network-restored resets it.
class IptvSocketService {
  StompClient? _stompClient;
  Timer? _reconnectionTimer;
  Timer? _connectionTimeoutTimer;
  Timer? _cooldownTimer;
  Timer? _watchdogTimer;
  StreamSubscription<bool>? _connectivitySubscription;

  final ConnectivityService _connectivityService = getIt<ConnectivityService>();

  DateTime? _lastMessageReceived;
  DateTime? _lastHeartbeatReceived;
  int _reconnectAttempts = 0;
  bool _isWebSocketConnected = false;
  bool _isConnecting = false;
  bool _shouldReconnect = true;

  /// Bumped on every connect; callbacks carrying an older value are stale.
  int _generation = 0;

  // Configuration
  static const int MAX_RECONNECT_ATTEMPTS = 20;
  static const Duration CONNECTION_TIMEOUT = Duration(seconds: 15);
  static const Duration STOMP_HEARTBEAT = Duration(seconds: 10);
  static const Duration WATCHDOG_INTERVAL = Duration(seconds: 15);

  /// Backend publishes /topic/heartbeat every 60s; allow two misses.
  static const Duration HEARTBEAT_TIMEOUT = Duration(seconds: 150);
  static const Duration MAX_ATTEMPTS_COOLDOWN = Duration(minutes: 5);

  String? _currentTvId;

  // Callbacks
  Function()? onTvUpdateReceived;
  Function()? onConnectionSuccess;
  Function(String)? onConnectionError;

  bool get isConnected => _isWebSocketConnected;
  bool get isConnecting => _isConnecting;
  DateTime? get lastMessageReceived => _lastMessageReceived;
  DateTime? get lastHeartbeatReceived => _lastHeartbeatReceived;

  /// Socket endpoint; overridable for tests.
  final String url;

  IptvSocketService({this.url = ApiConstants.wsUrl}) {
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivityService.connectionStream.listen((
      isConnected,
    ) {
      if (isConnected) {
        debugPrint('[IPTV-WS] 🌐 Internet restored - auto-reconnecting');
        resetAttempts();
        if (!_isWebSocketConnected && _currentTvId != null) {
          Future.delayed(const Duration(seconds: 2), () {
            if (_shouldReconnect &&
                _connectivityService.isConnected &&
                !_isWebSocketConnected) {
              reconnect();
            }
          });
        }
      } else {
        debugPrint('[IPTV-WS] 📵 Internet lost');
        // The socket is almost certainly dead; don't wait for the heartbeat
        // timeout to notice. Reconnect happens when the network returns.
        _markDisconnected();
        _reconnectionTimer?.cancel();
      }
    });
  }

  Future<void> connect(String tvId) async {
    // Remember the TV first so a later network-restore or watchdog tick can
    // connect even if this attempt is skipped.
    _currentTvId = tvId;
    _shouldReconnect = true;
    _startWatchdog();

    if (_isConnecting) {
      debugPrint('[IPTV-WS] ⏸️ Already connecting');
      return;
    }

    if (!_connectivityService.isConnected) {
      debugPrint('[IPTV-WS] ⏸️ No network - will connect when restored');
      return;
    }

    _isConnecting = true;
    _reconnectionTimer?.cancel();
    _connectionTimeoutTimer?.cancel();

    final generation = ++_generation;

    _connectionTimeoutTimer = Timer(CONNECTION_TIMEOUT, () {
      if (generation == _generation && _isConnecting) {
        debugPrint('[IPTV-WS] ⏱️ Connection timeout');
        _generation++; // ignore the abandoned client from here on
        _isConnecting = false;
        _teardownClient();
        _scheduleReconnection();
      }
    });

    // Clean up existing connection
    if (_stompClient != null) {
      _teardownClient();
      await Future.delayed(const Duration(milliseconds: 300));
      if (generation != _generation) return; // superseded meanwhile
    }

    debugPrint(
      '[IPTV-WS] 🔌 Connecting to $url for TV: $tvId',
    );

    bool isCurrent() => generation == _generation;

    final client = StompClient(
      config: StompConfig(
        url: url,
        onConnect: (StompFrame frame) {
          if (!isCurrent()) return;
          _connectionTimeoutTimer?.cancel();
          _isConnecting = false;
          _isWebSocketConnected = true;
          _lastMessageReceived = DateTime.now();
          _lastHeartbeatReceived = DateTime.now();
          _reconnectAttempts = 0;
          _cooldownTimer?.cancel();

          debugPrint(
            '[IPTV-WS] ✅ Connected for TV: $tvId '
            '(heart-beat ${frame.headers['heart-beat'] ?? 'none'})',
          );

          _subscribeAll(tvId);
          onConnectionSuccess?.call();
        },
        onWebSocketError: (dynamic error) {
          if (!isCurrent()) return;
          debugPrint('[IPTV-WS] ❌ WebSocket error: $error');
          _handleConnectionLost('WebSocket error: $error');
        },
        onStompError: (StompFrame frame) {
          if (!isCurrent()) return;
          debugPrint('[IPTV-WS] ❌ STOMP error: ${frame.body}');
          _handleConnectionLost('STOMP error: ${frame.body}');
        },
        // Abrupt close: server restart, network drop, missed STOMP heartbeats
        onWebSocketDone: () {
          if (!isCurrent()) return;
          debugPrint('[IPTV-WS] ⚠️ Socket closed');
          _handleConnectionLost('Socket closed');
        },
        // Clean DISCONNECT receipt; only happens if the server asks for it
        onDisconnect: (StompFrame frame) {
          if (!isCurrent()) return;
          debugPrint('[IPTV-WS] ⚠️ Disconnected');
          _handleConnectionLost('Disconnected');
        },
        beforeConnect: () async {
          debugPrint('[IPTV-WS] 🔗 Attempting connection...');
        },
        stompConnectHeaders: {},
        webSocketConnectHeaders: {},
        heartbeatIncoming: STOMP_HEARTBEAT,
        heartbeatOutgoing: STOMP_HEARTBEAT,
        connectionTimeout: CONNECTION_TIMEOUT,
        // We own reconnection; the library's built-in retry is off.
        reconnectDelay: Duration.zero,
      ),
    );
    _stompClient = client;

    try {
      client.activate();
    } catch (e) {
      debugPrint('[IPTV-WS] ❌ Failed to activate STOMP: $e');
      _handleConnectionLost('Failed to activate: $e');
    }
  }

  void _subscribeAll(String tvId) {
    final client = _stompClient;
    if (client == null) return;

    // TV layout changes
    client.subscribe(
      destination: '/topic/tv-layout/$tvId',
      callback: (StompFrame frame) {
        _lastMessageReceived = DateTime.now();
        debugPrint('[IPTV-WS] 📺 TV update received for TV: $tvId');
        onTvUpdateReceived?.call();
      },
    );

    // Full-screen notifications: one topic for all screens, one per TV
    for (final topic in [
      '/topic/tv-notification',
      '/topic/tv-notification/$tvId',
    ]) {
      client.subscribe(destination: topic, callback: _onNotificationFrame);
    }

    // App-level heartbeat from the backend (every 60s)
    client.subscribe(
      destination: '/topic/heartbeat',
      callback: (StompFrame frame) {
        _lastHeartbeatReceived = DateTime.now();
        debugPrint('[IPTV-WS] 💓 Heartbeat received');
      },
    );
  }

  void _onNotificationFrame(StompFrame frame) {
    _lastMessageReceived = DateTime.now();
    if (frame.body == null) return;
    try {
      final event = jsonDecode(frame.body!) as Map<String, dynamic>;
      debugPrint('[IPTV-WS] 🔔 Notification ${event['action']} ${event['id']}');
      TvNotificationController.instance.handleEvent(event);
    } catch (e) {
      debugPrint('[IPTV-WS] ⚠️ Bad notification payload: $e');
    }
  }

  void _handleConnectionLost(String reason) {
    _connectionTimeoutTimer?.cancel();
    final wasActive = _isWebSocketConnected || _isConnecting;
    _isConnecting = false;
    _isWebSocketConnected = false;
    if (wasActive) onConnectionError?.call(reason);
    _scheduleReconnection();
  }

  void _markDisconnected() {
    if (!_isWebSocketConnected && !_isConnecting) return;
    _generation++; // ignore whatever the old client reports from now on
    _connectionTimeoutTimer?.cancel();
    _isConnecting = false;
    _isWebSocketConnected = false;
    _teardownClient();
  }

  void _teardownClient() {
    final client = _stompClient;
    _stompClient = null;
    if (client == null) return;
    try {
      client.deactivate();
    } catch (e) {
      debugPrint('[IPTV-WS] ⚠️ Error during deactivation: $e');
    }
  }

  /// Periodic self-check, independent of whoever owns this service.
  void _startWatchdog() {
    if (_watchdogTimer != null) return;
    _watchdogTimer = Timer.periodic(WATCHDOG_INTERVAL, (_) => _watchdogTick());
  }

  void _watchdogTick() {
    if (!_shouldReconnect || _currentTvId == null) return;
    if (!_connectivityService.isConnected) return;

    if (_isWebSocketConnected) {
      final lastHeartbeat = _lastHeartbeatReceived;
      if (lastHeartbeat != null &&
          DateTime.now().difference(lastHeartbeat) > HEARTBEAT_TIMEOUT) {
        debugPrint(
          '[IPTV-WS] 💔 No heartbeat for '
          '${DateTime.now().difference(lastHeartbeat).inSeconds}s - reconnecting',
        );
        reconnect();
      }
      return;
    }

    // Down, and nothing is in flight or queued: get things moving again.
    final reconnectQueued =
        (_reconnectionTimer?.isActive ?? false) ||
        (_cooldownTimer?.isActive ?? false);
    if (!_isConnecting && !reconnectQueued) {
      debugPrint('[IPTV-WS] 🩺 Watchdog: socket down with nothing queued');
      _scheduleReconnection();
    }
  }

  Future<void> reconnect() async {
    if (!_connectivityService.isConnected) {
      debugPrint('[IPTV-WS] ⏸️ Cannot reconnect - no network');
      return;
    }
    if (_currentTvId == null) return;

    debugPrint('[IPTV-WS] 🔄 Forcing WebSocket reconnection');
    _generation++; // drop callbacks from the client being replaced
    _isWebSocketConnected = false;
    _isConnecting = false;
    _reconnectionTimer?.cancel();

    await connect(_currentTvId!);
  }

  void _scheduleReconnection() {
    if (!_shouldReconnect || _isConnecting || _currentTvId == null) {
      return;
    }

    if (!_connectivityService.isConnected) {
      debugPrint('[IPTV-WS] ⏸️ No network - will auto-reconnect when restored');
      return;
    }

    if (_reconnectionTimer?.isActive ?? false) return; // already queued

    if (_reconnectAttempts >= MAX_RECONNECT_ATTEMPTS) {
      if (_cooldownTimer?.isActive ?? false) return;
      debugPrint(
        '[IPTV-WS] ⛔ Max reconnection attempts reached - '
        'resting ${MAX_ATTEMPTS_COOLDOWN.inMinutes} min',
      );
      _cooldownTimer = Timer(MAX_ATTEMPTS_COOLDOWN, () {
        _reconnectAttempts = 0;
        _scheduleReconnection();
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

    _reconnectionTimer = Timer(delay, () async {
      if (_shouldReconnect &&
          !_isConnecting &&
          !_isWebSocketConnected &&
          _connectivityService.isConnected &&
          _currentTvId != null) {
        await connect(_currentTvId!);
      }
    });
  }

  void resetAttempts() {
    _reconnectAttempts = 0;
    _cooldownTimer?.cancel();
  }

  void dispose() {
    _shouldReconnect = false;
    _generation++;
    _reconnectionTimer?.cancel();
    _connectionTimeoutTimer?.cancel();
    _cooldownTimer?.cancel();
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
    _connectivitySubscription?.cancel();
    _isConnecting = false;
    _isWebSocketConnected = false;
    _teardownClient();
  }
}
