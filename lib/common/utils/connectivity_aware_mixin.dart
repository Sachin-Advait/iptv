import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oman_tv/common/utils/get_it.dart';
import 'package:oman_tv/services/connectivity_service.dart';

mixin ConnectivityAwareMixin<T extends StatefulWidget> on State<T> {
  late ConnectivityService _connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivityService = getIt.get<ConnectivityService>();
    _connectivitySubscription = _connectivityService.connectionStream.listen((
      isConnected,
    ) {
      if (isConnected) {
        debugPrint('🔄 Internet reconnected');
        onConnectivityRestored();
      }
    });
  }

  void onConnectivityRestored();

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
