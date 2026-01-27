class TickerModel {
  final bool success;
  final String message;
  final List<String> data;

  TickerModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TickerModel.fromJson(Map<String, dynamic> json) {
    return TickerModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: List<String>.from(json['data'] ?? []),
    );
  }
}
