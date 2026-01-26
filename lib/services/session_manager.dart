// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class SessionManager {
  static final _userStorage = GetStorage();

  static const String _tokenKey = 'Token Key';
  static const String _userId = 'UserId ID';
  static const String _counter = 'counter ID';

  static Future<void> saveToken(String token) async {
    await _userStorage.write(_tokenKey, token);
    debugPrint("User ID saved ==> $token.");
  }

  static String getToken() {
    String token = _userStorage.read<String?>(_tokenKey) ?? '';
    debugPrint("User ID ==> $token.");
    return token;
  }

  static Future<void> saveUserId(String userId) async {
    await _userStorage.write(_userId, userId);
    debugPrint("UserId saved ==> $userId.");
  }

  static String getUserId() {
    String UserId = _userStorage.read<String?>(_userId) ?? '';
    debugPrint("UserId Id ==> $UserId.");
    return UserId;
  }

  static Future<void> saveCounter(String counter) async {
    await _userStorage.write(_counter, counter);
    debugPrint("Counter saved ==> $counter.");
  }

  static String getCounter() {
    String counter = _userStorage.read<String?>(_counter) ?? '';
    return counter;
  }

  static void clearSession() {
    _userStorage.erase();
    debugPrint("Session Cleared.");
  }
}
