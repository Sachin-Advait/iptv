part of 'dashboard_cubit.dart';

enum DashboardStatus { initial, loading, success, error }

class DashboardState extends Equatable {
  final DashboardStatus dashboardStatus;
  final DashboardDetails? dashboardData;
  final String? errorMessage;
  final bool isNetworkConnected;
  final ConnectivityResult? connectivityStatus;
  final bool wasNetworkRestored;

  const DashboardState({
    this.dashboardStatus = DashboardStatus.initial,
    this.dashboardData,
    this.errorMessage,
    this.isNetworkConnected = true,
    this.connectivityStatus,
    this.wasNetworkRestored = false,
  });

  DashboardState copyWith({
    DashboardStatus? dashboardStatus,
    DashboardDetails? dashboardData,
    String? errorMessage,
    bool? isNetworkConnected,
    ConnectivityResult? connectivityStatus,
    bool? wasNetworkRestored,
  }) {
    return DashboardState(
      dashboardStatus: dashboardStatus ?? this.dashboardStatus,
      dashboardData: dashboardData ?? this.dashboardData,
      errorMessage: errorMessage,
      isNetworkConnected: isNetworkConnected ?? this.isNetworkConnected,
      connectivityStatus: connectivityStatus ?? this.connectivityStatus,
      wasNetworkRestored: wasNetworkRestored ?? this.wasNetworkRestored,
    );
  }

  @override
  List<Object?> get props => [
    dashboardStatus,
    dashboardData,
    errorMessage,
    isNetworkConnected,
    connectivityStatus,
    wasNetworkRestored,
  ];
}
