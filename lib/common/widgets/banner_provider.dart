import 'package:oman_tv/models/media_model.dart';

class BannerProvider {
  final String? staticUrl;
  final MediaData? mediaData;
  final String? specificImageUrl;

  BannerProvider.static(String url)
    : staticUrl = url,
      mediaData = null,
      specificImageUrl = null;

  BannerProvider.fromMedia(MediaData media, {String? specificUrl})
    : staticUrl = null,
      mediaData = media,
      specificImageUrl = specificUrl;

  String get imageUrl {
    if (staticUrl != null) return staticUrl!;
    if (specificImageUrl != null) return specificImageUrl!;
    if (mediaData != null && mediaData!.imageUrl.isNotEmpty) {
      return mediaData!.imageUrl.first;
    }
    return '';
  }

  bool get isApiBanner => mediaData != null;
  bool get isActive => mediaData?.active ?? false;
  String get title => mediaData?.title ?? '';
  String? get videoUrl => mediaData?.videoUrl;
}
