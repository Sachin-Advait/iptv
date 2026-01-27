import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';

class NewsTicker extends StatefulWidget {
  const NewsTicker({super.key});

  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker> {
  late ScrollController _scrollController;
  Timer? _scrollTimer;

  final List<String> newsItems = [
    "Welcome to the Military and Security Services Pension Fund. We are happy to serve you.",
    "مرحبا بكم في صندوق تقاعد الأجهزة العسكرية والأمنية ، يسعدنا خدمتكم",
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Start auto-scrolling after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
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
    final newsText = newsItems.join("    -    ");
    // Duplicate the text for seamless looping
    final displayText = "$newsText    -    $newsText    -    $newsText";

    return Container(
      height: 40,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SingleChildScrollView(
          controller: _scrollController,
          reverse: true,
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
      ),
    );
  }
}
