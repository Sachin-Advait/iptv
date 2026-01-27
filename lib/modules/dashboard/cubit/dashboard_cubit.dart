import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/common/constants/api_constants.dart';
import 'package:oman_tv/common/utils/get_it.dart';
import 'package:oman_tv/models/ticker_model.dart';
import 'package:oman_tv/services/api_client.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final ApiClient _apiClient = getIt<ApiClient>();

  DashboardCubit() : super(DashboardState());

  Future<void> fetchTickerData() async {
    emit(
      state.copyWith(tickerStatus: TickerStatus.loading, errorMessage: null),
    );

    final response = await _apiClient.getApi(ApiConstants.tickers);

    if (response != null && response.statusCode == 200) {
      final tickerModel = TickerModel.fromJson(response.data);

      emit(
        state.copyWith(
          tickerStatus: TickerStatus.success,
          tickerData: tickerModel.data,
        ),
      );
    } else {
      emit(
        state.copyWith(
          tickerStatus: TickerStatus.error,
          errorMessage: 'Failed to load ticker data',
        ),
      );
    }
  }
}
