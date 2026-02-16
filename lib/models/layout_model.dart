class LayoutModel {
  final int id;
  final String? name;
  final String? layoutType;
  final String? orientation;
  final bool videoEnabled;
  final bool bannerEnabled;
  final bool channelEnabled;
  final bool tickerEnabled;
  final Map<String, dynamic>? configJson;

  LayoutModel({
    required this.id,
    this.name,
    this.layoutType,
    this.orientation,
    required this.videoEnabled,
    required this.bannerEnabled,
    required this.channelEnabled,
    required this.tickerEnabled,
    this.configJson,
  });

  factory LayoutModel.fromJson(Map<String, dynamic> json) {
    return LayoutModel(
      id: json['id'],
      name: json['name'],
      layoutType: json['layoutType'],
      orientation: json['orientation'],
      videoEnabled: json['videoEnabled'] ?? false,
      bannerEnabled: json['bannerEnabled'] ?? false,
      channelEnabled: json['channelEnabled'] ?? false,
      tickerEnabled: json['tickerEnabled'] ?? false,
      configJson: json['configJson'] != null
          ? Map<String, dynamic>.from(json['configJson'])
          : null,
    );
  }
}
