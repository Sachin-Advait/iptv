// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'dashboard_cubit.dart';

enum TickerStatus { initial, loading, success, error }

class DashboardState extends Equatable {
  final TickerStatus tickerStatus;
  final List<String> tickerData;
  final LayoutModel? currentLayout;
  final String? errorMessage;
  final bool isNetworkConnected;
  final ConnectivityResult? connectivityStatus;
  final bool wasNetworkRestored;

  const DashboardState({
    this.tickerStatus = TickerStatus.initial,
    this.tickerData = const [],
    this.currentLayout,
    this.errorMessage,
    this.isNetworkConnected = true,
    this.connectivityStatus,
    this.wasNetworkRestored = false,
  });

  DashboardState copyWith({
    TickerStatus? tickerStatus,
    List<String>? tickerData,
    LayoutModel? currentLayout,
    String? errorMessage,
    bool? isNetworkConnected,
    ConnectivityResult? connectivityStatus,
    bool? wasNetworkRestored,
  }) {
    return DashboardState(
      tickerStatus: tickerStatus ?? this.tickerStatus,
      tickerData: tickerData ?? this.tickerData,
      currentLayout: currentLayout ?? this.currentLayout,
      errorMessage: errorMessage,
      isNetworkConnected: isNetworkConnected ?? this.isNetworkConnected,
      connectivityStatus: connectivityStatus ?? this.connectivityStatus,
      wasNetworkRestored: wasNetworkRestored ?? this.wasNetworkRestored,
    );
  }

  @override
  List<Object?> get props => [
    tickerStatus,
    tickerData,
    currentLayout,
    errorMessage,
    isNetworkConnected,
    connectivityStatus,
    wasNetworkRestored,
  ];
}
