import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/modules/dashboard/cubit/dashboard_cubit.dart';

class NewsTicker extends StatefulWidget {
  const NewsTicker({super.key, this.color});

  final Color? color;

  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker> {
  Timer? _tickerTimer;
  late ScrollController _tickerScrollController;

  @override
  void initState() {
    _tickerScrollController = ScrollController();
    super.initState();
  }

  void _startTickerAutoScroll() {
    _tickerTimer?.cancel();

    _tickerTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (_tickerScrollController.hasClients) {
        final max = _tickerScrollController.position.maxScrollExtent;
        final current = _tickerScrollController.offset;

        if (current >= max) {
          _tickerScrollController.jumpTo(0);
        } else {
          _tickerScrollController.jumpTo(current + 2);
        }
      }
    });
  }

  void _stopTickerAutoScroll() {
    _tickerTimer?.cancel();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _tickerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.dashboardStatus == DashboardStatus.loading ||
            state.dashboardStatus == DashboardStatus.initial) {
          return TickerShimmer(scrollController: _tickerScrollController);
        }
        if (state.dashboardData?.tickerZone.isEmpty ?? true) {
          return const SizedBox();
        }

        if (state.dashboardStatus == DashboardStatus.success &&
            state.dashboardData!.tickerZone.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startTickerAutoScroll();
          });
        } else {
          _stopTickerAutoScroll();
        }

        return Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                controller: _tickerScrollController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.dashboardData?.tickerZone.length,
                itemBuilder: (context, index) {
                  final title = state.dashboardData!.tickerZone[index].title;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: widget.color ?? AppColors.almostBlack,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class TickerShimmer extends StatefulWidget {
  const TickerShimmer({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  State<TickerShimmer> createState() => _TickerShimmerState();
}

class _TickerShimmerState extends State<TickerShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.lightBeige,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: [
            // Create multiple shimmer items to simulate scrolling text
            ...List.generate(10, (index) {
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 20 : 0, right: 20),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _animation.value,
                      child: Container(
                        width: 200,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
