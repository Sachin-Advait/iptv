import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:oman_tv/common/utils/get_it.dart';
import 'package:oman_tv/services/connectivity_service.dart';
import 'package:oman_tv/services/iptv_socket_service.dart';

/// Connectivity we can flip from the test.
class FakeConnectivityService implements ConnectivityService {
  final _controller = StreamController<bool>.broadcast();
  bool _connected;

  FakeConnectivityService({bool connected = true}) : _connected = connected;

  void set(bool value) {
    _connected = value;
    _controller.add(value);
  }

  @override
  Stream<bool> get connectionStream => _controller.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<bool> checkConnection() async => _connected;

  @override
  void dispose() => _controller.close();
}

/// Just enough of a STOMP broker: answers CONNECT, records SUBSCRIBEs.
class FakeStompServer {
  late HttpServer _server;
  final List<WebSocket> sockets = [];
  final List<String> subscriptions = [];
  int connects = 0;

  /// heart-beat header the broker advertises in CONNECTED.
  String heartBeat = '0,0';

  String get url => 'ws://127.0.0.1:${_server.port}/ws';

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.listen((req) async {
      final ws = await WebSocketTransformer.upgrade(req);
      sockets.add(ws);
      ws.listen((data) {
        final text = data is String ? data : String.fromCharCodes(data);
        if (text.startsWith('CONNECT')) {
          connects++;
          ws.add('CONNECTED\nversion:1.2\nheart-beat:$heartBeat\n\n\x00');
        } else if (text.startsWith('SUBSCRIBE')) {
          final dest = RegExp(r'destination:(.*)').firstMatch(text)?.group(1);
          if (dest != null) subscriptions.add(dest.trim());
        }
      }, onError: (_) {});
    });
  }

  /// Server-side drop, like a backend restart.
  Future<void> dropAll() async {
    for (final s in List.of(sockets)) {
      await s.close();
    }
    sockets.clear();
  }

  Future<void> stop() async {
    await dropAll();
    await _server.close(force: true);
  }
}

Future<void> waitFor(bool Function() condition, Duration timeout) async {
  final end = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(end)) {
      throw TimeoutException('condition not met within $timeout');
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

void main() {
  late FakeStompServer server;
  late FakeConnectivityService connectivity;
  late IptvSocketService service;

  setUp(() async {
    await getIt.reset();
    server = FakeStompServer();
    await server.start();
  });

  tearDown(() async {
    service.dispose();
    await server.stop();
  });

  void build({bool online = true}) {
    connectivity = FakeConnectivityService(connected: online);
    getIt.registerSingleton<ConnectivityService>(connectivity);
    service = IptvSocketService(url: server.url);
  }

  test('connects and subscribes to TV, notification and heartbeat topics',
      () async {
    build();
    await service.connect('7');
    await waitFor(() => service.isConnected, const Duration(seconds: 5));
    await waitFor(
        () => server.subscriptions.length == 4, const Duration(seconds: 5));
    expect(
      server.subscriptions,
      containsAll([
        '/topic/tv-layout/7',
        '/topic/tv-notification',
        '/topic/tv-notification/7',
        '/topic/heartbeat',
      ]),
    );
  });

  test('reconnects after the server drops the socket, and stays connected',
      () async {
    build();
    var successes = 0;
    service.onConnectionSuccess = () => successes++;
    await service.connect('7');
    await waitFor(() => service.isConnected, const Duration(seconds: 5));

    await server.dropAll();
    await waitFor(() => !service.isConnected, const Duration(seconds: 5));

    // First backoff step is 3s
    await waitFor(() => server.connects == 2 && service.isConnected,
        const Duration(seconds: 10));
    expect(successes, 2);

    // A late event from the old socket must not knock the new one down
    await Future.delayed(const Duration(seconds: 4));
    expect(service.isConnected, isTrue);
    expect(server.connects, 2);
  });

  test('TV that boots offline connects once the network comes up', () async {
    build(online: false);
    await service.connect('7');
    await Future.delayed(const Duration(seconds: 1));
    expect(server.connects, 0);

    connectivity.set(true);
    await waitFor(() => service.isConnected, const Duration(seconds: 8));
    expect(server.connects, 1);
  });

  test('half-open socket is detected by STOMP heartbeats and replaced',
      () async {
    // Broker promises a heartbeat every 1s, then never sends one.
    server.heartBeat = '1000,0';
    build();
    await service.connect('7');
    await waitFor(() => service.isConnected, const Duration(seconds: 5));

    // Client checks every max(10s, 1s) and gives up after 2x that silence.
    await waitFor(() => server.connects >= 2, const Duration(seconds: 50));
  }, timeout: const Timeout(Duration(seconds: 70)));
}
