import 'package:flutter/material.dart';
import 'package:oman_tv/models/dashboard_model.dart';

class NewsTicker extends StatelessWidget {
  final List<TickerZone> items;
  final ScrollController controller;

  const NewsTicker({super.key, required this.items, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox(height: 40);

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
  }
}
