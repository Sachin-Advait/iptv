// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/common/constants/api_constants.dart';
import 'package:oman_tv/common/utils/get_it.dart';
import 'package:oman_tv/models/announcement_model.dart';
import 'package:oman_tv/services/api_client.dart';

part 'announcement_state.dart';

class AnnouncementCubit extends Cubit<AnnouncementState> {
  final ApiClient _apiClient = getIt<ApiClient>();
  Timer? _refreshTimer;

  // Pick up announcements added or expired from the admin portal
  static const Duration REFRESH_INTERVAL = Duration(minutes: 1);

  AnnouncementCubit() : super(const AnnouncementState());

  Future<void> start() async {
    await fetchAnnouncements();
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      REFRESH_INTERVAL,
      (_) => fetchAnnouncements(isRefresh: true),
    );
  }

  Future<void> fetchAnnouncements({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(state.copyWith(status: AnnouncementStatus.loading));
    }

    try {
      final response = await _apiClient.getApi(
        ApiConstants.announcements,
        enableRetry: !isRefresh,
      );

      if (response != null && response.statusCode == 200) {
        final list = (response.data['data'] as List? ?? [])
            .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>))
            .toList();
        emit(
          state.copyWith(
            status: AnnouncementStatus.success,
            announcements: list,
          ),
        );
      } else {
        throw Exception('Failed to load announcements');
      }
    } catch (e) {
      debugPrint('[ANNOUNCEMENT] ❌ Load failed: $e');
      // Keep showing the last list on a failed background refresh
      if (!isRefresh || state.status != AnnouncementStatus.success) {
        emit(state.copyWith(status: AnnouncementStatus.error));
      }
    }
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
