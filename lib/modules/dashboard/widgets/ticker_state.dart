import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';
import 'package:oman_tv/modules/dashboard/cubit/dashboard_cubit.dart';

class NewsTicker extends StatefulWidget {
  const NewsTicker({super.key, required this.dashboardCubit});

  final DashboardCubit dashboardCubit;

  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker> {
  late ScrollController _scrollController;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();

    _scrollTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;

        if (currentScroll >= maxScroll) {
          // Reset to start for continuous loop
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(
            currentScroll + 3,
            duration: const Duration(milliseconds: 30),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      bloc: widget.dashboardCubit,
      builder: (context, state) {
        // Start/stop auto-scroll based on ticker status
        if (state.tickerStatus == TickerStatus.success &&
            state.tickerData.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startAutoScroll();
          });
        } else {
          _scrollTimer?.cancel();
        }

        return Container(
          height: 40,
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildTickerContent(context, state),
          ),
        );
      },
    );
  }

  Widget _buildTickerContent(BuildContext context, DashboardState state) {
    switch (state.tickerStatus) {
      case TickerStatus.initial:
      case TickerStatus.loading:
        return _buildTickerShimmer();

      case TickerStatus.success:
        if (state.tickerData.isEmpty) {
          return _buildEmptyTicker();
        }
        return _buildAutoScrollingTicker(state.tickerData);

      case TickerStatus.error:
        return _buildErrorTicker(state.errorMessage);
    }
  }

  Widget _buildAutoScrollingTicker(List<String> newsItems) {
    // Join all news items with separator
    final newsText = newsItems.join("    -    ");
    // Duplicate for seamless looping
    final displayText = "$newsText    -    $newsText    -    $newsText";

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            displayText,
            style: context.semiBold.copyWith(
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTicker() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        'No news available',
        style: context.medium.copyWith(fontSize: 16, color: AppColors.primary),
      ),
    );
  }

  Widget _buildErrorTicker(String? errorMessage) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.red, size: 20),
          SizedBox(width: 8),
          Text(
            'Failed to load news',
            style: context.medium.copyWith(fontSize: 14, color: AppColors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildTickerShimmer() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.lightBeige,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: [
            // Create multiple shimmer items to simulate scrolling text
            ...List.generate(10, (index) {
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 20 : 0, right: 20),
                child: TickerShimmerItem(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class TickerShimmerItem extends StatefulWidget {
  const TickerShimmerItem({super.key});

  @override
  State<TickerShimmerItem> createState() => _TickerShimmerItemState();
}

class _TickerShimmerItemState extends State<TickerShimmerItem>
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 200,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }
}
