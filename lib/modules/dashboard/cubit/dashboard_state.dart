part of 'dashboard_cubit.dart';

enum TickerStatus { initial, loading, success, error }

class DashboardState extends Equatable {
  final TickerStatus tickerStatus;
  final List<String> tickerData;
  final String? errorMessage;

  const DashboardState({
    this.tickerStatus = TickerStatus.initial,
    this.tickerData = const [],
    this.errorMessage,
  });

  DashboardState copyWith({
    TickerStatus? tickerStatus,
    List<String>? tickerData,
    String? errorMessage,
  }) {
    return DashboardState(
      tickerStatus: tickerStatus ?? this.tickerStatus,
      tickerData: tickerData ?? this.tickerData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [tickerStatus, tickerData, errorMessage];
}
