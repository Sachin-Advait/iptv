import 'package:oman_tv/common/constants/api_constants.dart';
import 'package:oman_tv/models/display_token.dart';
import 'package:oman_tv/services/api_client.dart';

class VisitorTvRepo {
  final ApiClient _apiClient;

  VisitorTvRepo(this._apiClient);

  Future<TVDisplayResponse> getDisplayData(String branchId) async {
    final response = await _apiClient.getApi(
      '${ApiConstants.tvDisplay}$branchId',
    );

    if (response != null && response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return TVDisplayResponse.fromJson(data);
      }
    }
    throw Exception('Failed to load display data');
  }
}
