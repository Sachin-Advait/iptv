part of 'announcement_cubit.dart';

enum AnnouncementStatus { initial, loading, success, error }

class AnnouncementState extends Equatable {
  final AnnouncementStatus status;
  final List<AnnouncementModel> announcements;

  const AnnouncementState({
    this.status = AnnouncementStatus.initial,
    this.announcements = const [],
  });

  AnnouncementState copyWith({
    AnnouncementStatus? status,
    List<AnnouncementModel>? announcements,
  }) {
    return AnnouncementState(
      status: status ?? this.status,
      announcements: announcements ?? this.announcements,
    );
  }

  @override
  List<Object?> get props => [status, announcements];
}
