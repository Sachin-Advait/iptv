part of 'meeting_tv_bloc.dart';

abstract class TvDisplayState extends Equatable {
  const TvDisplayState();

  @override
  List<Object?> get props => [];
}

class TvDisplayInitial extends TvDisplayState {}

class TvDisplayLoading extends TvDisplayState {}

class TvDisplayLoaded extends TvDisplayState {
  final TvDisplayDetails tvDisplayDetails;
  final bool isNetworkConnected;

  const TvDisplayLoaded({
    required this.tvDisplayDetails,
    this.isNetworkConnected = true,
  });

  TvDisplayLoaded copyWith({
    TvDisplayDetails? tvDisplayDetails,
    bool? isNetworkConnected,
  }) {
    return TvDisplayLoaded(
      tvDisplayDetails: tvDisplayDetails ?? this.tvDisplayDetails,
      isNetworkConnected: isNetworkConnected ?? this.isNetworkConnected,
    );
  }

  @override
  List<Object?> get props => [tvDisplayDetails, isNetworkConnected];
}

class TvDisplayError extends TvDisplayState {
  final String message;
  final bool isNetworkError;

  const TvDisplayError({required this.message, this.isNetworkError = false});

  @override
  List<Object?> get props => [message, isNetworkError];
}
