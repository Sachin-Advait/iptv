part of 'home_cubit.dart';

enum MediaStatus { initial, loading, success, error }

class HomeState extends Equatable {
  final MediaStatus mediaStatus;
  final MediaData? mediaData;
  final String? errorMessage;

  const HomeState({
    this.mediaStatus = MediaStatus.initial,
    this.mediaData,
    this.errorMessage,
  });

  HomeState copyWith({
    MediaStatus? mediaStatus,
    MediaData? mediaData,
    String? errorMessage,
  }) {
    return HomeState(
      mediaStatus: mediaStatus ?? this.mediaStatus,
      mediaData: mediaData ?? this.mediaData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [mediaStatus, mediaData, errorMessage];
}
