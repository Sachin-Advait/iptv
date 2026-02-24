part of 'meeting_tv_bloc.dart';

abstract class TvDisplayEvent extends Equatable {
  const TvDisplayEvent();

  @override
  List<Object?> get props => [];
}

class LoadTvDisplayData extends TvDisplayEvent {}

class RefreshTvDisplayData extends TvDisplayEvent {}

class UpdateTvDisplayFromSocketEvent extends TvDisplayEvent {
  final dynamic displayData;
  const UpdateTvDisplayFromSocketEvent(this.displayData);

  @override
  List<Object?> get props => [displayData];
}

class NetworkConnectivityChangedEvent extends TvDisplayEvent {
  final ConnectivityResult result;
  const NetworkConnectivityChangedEvent(this.result);

  @override
  List<Object?> get props => [result];
}

class UpdateConnectionStatusEvent extends TvDisplayEvent {
  final bool isNetworkConnected;
  const UpdateConnectionStatusEvent({required this.isNetworkConnected});

  @override
  List<Object?> get props => [isNetworkConnected];
}

class OnAppResumedEvent extends TvDisplayEvent {
  const OnAppResumedEvent();
}

class ManualRetryEvent extends TvDisplayEvent {
  const ManualRetryEvent();
}
