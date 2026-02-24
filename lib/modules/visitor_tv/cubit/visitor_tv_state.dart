// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'visitor_tv_cubit.dart';

abstract class VisitorTvState {}

class TVDisplayInitial extends VisitorTvState {}

class TVDisplayLoading extends VisitorTvState {}

class TVDisplayLoaded extends VisitorTvState {
  final List<DisplayToken> latestCalls;
  final List<DisplayToken> nowServing;
  final List<String> upcomingTokens;
  final List<String> holdTokens;
  final bool isNetworkConnected;
  final ConnectivityResult connectivityStatus;
  final bool wasNetworkRestored;
  final String? errorMessage;

  TVDisplayLoaded({
    required this.latestCalls,
    required this.nowServing,
    required this.upcomingTokens,
    required this.holdTokens,
    this.isNetworkConnected = true,
    this.connectivityStatus = ConnectivityResult.none,
    this.wasNetworkRestored = false,
    this.errorMessage,
  });

  TVDisplayLoaded copyWith({
    List<DisplayToken>? latestCalls,
    List<DisplayToken>? nowServing,
    List<String>? upcomingTokens,
    List<String>? holdTokens,
    bool? isNetworkConnected,
    ConnectivityResult? connectivityStatus,
    bool? wasNetworkRestored,
    String? errorMessage,
  }) {
    return TVDisplayLoaded(
      latestCalls: latestCalls ?? this.latestCalls,
      nowServing: nowServing ?? this.nowServing,
      upcomingTokens: upcomingTokens ?? this.upcomingTokens,
      holdTokens: holdTokens ?? this.holdTokens,
      isNetworkConnected: isNetworkConnected ?? this.isNetworkConnected,
      connectivityStatus: connectivityStatus ?? this.connectivityStatus,
      wasNetworkRestored: wasNetworkRestored ?? this.wasNetworkRestored,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TVDisplayError extends VisitorTvState {
  final String message;
  final bool isNetworkError;

  TVDisplayError(this.message, {this.isNetworkError = false});
}
