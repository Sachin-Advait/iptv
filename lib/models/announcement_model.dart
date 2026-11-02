class AnnouncementModel {
  final int id;
  final String title;
  final String? subtitle;
  final String? description;

  const AnnouncementModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
    );
  }
}
