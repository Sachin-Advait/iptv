// models/live_media_model.dart
class MediaModel {
  final bool success;
  final String message;
  final List<MediaData> data;

  MediaModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => MediaData.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class MediaData {
  final bool active;
  final String category;
  final String createdAt;
  final int id;
  final List<dynamic> imageUrl;
  final String mediaType;
  final String title;
  final String updatedAt;
  final String videoUrl;

  MediaData({
    required this.active,
    required this.category,
    required this.createdAt,
    required this.id,
    required this.imageUrl,
    required this.mediaType,
    required this.title,
    required this.updatedAt,
    required this.videoUrl,
  });

  factory MediaData.fromJson(Map<String, dynamic> json) {
    return MediaData(
      active: json['active'] ?? false,
      category: json['category'] ?? '',
      createdAt: json['createdAt'] ?? '',
      id: json['id'] ?? 0,
      imageUrl: json['imageUrls'] ?? '',
      mediaType: json['mediaType'] ?? '',
      title: json['title'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
    );
  }
}
