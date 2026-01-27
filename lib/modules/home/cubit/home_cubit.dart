import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/common/utils/get_it.dart';
import 'package:oman_tv/models/media_model.dart';
import 'package:oman_tv/services/api_client.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final _apiClient = getIt<ApiClient>();

  HomeCubit() : super(const HomeState());

  Future<void> fetchMedia(String url) async {
    emit(state.copyWith(mediaStatus: MediaStatus.loading, errorMessage: null));

    final response = await _apiClient.getApi(url);

    if (response != null && response.statusCode == 200) {
      final mediaData = MediaModel.fromJson(response.data);

      emit(
        state.copyWith(
          mediaStatus: MediaStatus.success,
          mediaData: mediaData.data[0],
        ),
      );
    } else {
      emit(
        state.copyWith(
          mediaStatus: MediaStatus.error,
          errorMessage: 'Failed to load live media',
        ),
      );
    }
  }
}
