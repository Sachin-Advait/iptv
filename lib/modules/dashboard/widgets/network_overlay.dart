import 'package:flutter/material.dart';
import 'package:oman_tv/modules/dashboard/cubit/dashboard_cubit.dart';

class NetworkOverlay extends StatelessWidget {
  const NetworkOverlay({super.key, required DashboardCubit dashboardCubit})
    : _dashboardCubit = dashboardCubit;

  final DashboardCubit _dashboardCubit;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text(
              'No Internet Connection',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _dashboardCubit.manualRetry(),
              child: const Icon(Icons.refresh, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
