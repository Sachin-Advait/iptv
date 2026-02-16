import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/models/dashboard_model.dart';
import 'package:oman_tv/modules/dashboard/cubit/dashboard_cubit.dart';

class NewsTicker extends StatelessWidget {
  final List<TickerZone> items;
  final ScrollController controller;

  const NewsTicker({super.key, required this.items, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.dashboardStatus == DashboardStatus.loading ||
            state.dashboardStatus == DashboardStatus.initial) {
          return TickerShimmer(scrollController: controller);
        }
        if (items.isEmpty) return const SizedBox();
        return Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                controller: controller,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final title = items[index].title;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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
