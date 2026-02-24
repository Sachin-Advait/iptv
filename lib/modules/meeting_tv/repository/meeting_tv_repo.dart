// modules/home/repository/home_repository.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oman_tv/common/constants/api_constants.dart';
import 'package:oman_tv/models/tv_display_response.dart';

class MeetingTvRepo {
  Future<TvDisplayResponse> getTvDisplayData() async {
    // try {
    debugPrint('🔄 API CALL: GET ${ApiConstants.meetingTvDisplay}');

    final response = await http
        .get(
          Uri.parse(ApiConstants.meetingTvDisplay),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 30));

    debugPrint('📡 RESPONSE STATUS: ${response.statusCode}');
    debugPrint('📦 RESPONSE BODY: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return TvDisplayResponse.fromJson(jsonResponse);
    } else {
      debugPrint('❌ HTTP ERROR: ${response.statusCode}');
      return TvDisplayResponse(
        status: false,
        message: 'HTTP Error: ${response.statusCode}',
        data: null,
      );
    }
    // } catch (e) {
    //   debugPrint('❌ API EXCEPTION: $e');
    //   return TvDisplayResponse(
    //     status: false,
    //     message: 'Network error: $e',
    //     data: null,
    //   );
    // }
  }
}
