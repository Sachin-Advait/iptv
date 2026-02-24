import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/configs/assets/app_images.dart';
import 'package:oman_tv/configs/lang/localization_cubit.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/modules/visitor_tv/cubit/visitor_tv_cubit.dart';
import 'package:oman_tv/modules/visitor_tv/pages/components/custom_error.dart';
import 'package:oman_tv/modules/visitor_tv/pages/components/header.dart';
import 'package:oman_tv/modules/visitor_tv/pages/components/tv_content.dart';

class VisitorTvPage extends StatefulWidget {
  const VisitorTvPage({super.key, this.videoUrl});

  final String? videoUrl;

  @override
  State<VisitorTvPage> createState() => _VisitorTvPageState();
}

class _VisitorTvPageState extends State<VisitorTvPage>
    with WidgetsBindingObserver {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    changeOr();
    WidgetsBinding.instance.addObserver(this);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisitorTvCubit>().loadDisplayData(
        "025e3fc9-4557-4d8c-b65d-964ef9b2fa70",
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // When app comes back to foreground, check connectivity and reconnect
      context.read<VisitorTvCubit>().onAppResumed();
    }
  }

  Future<void> changeOr() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = context.currentLocale.languageCode == 'ar';
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor = screenHeight / 900;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImages.bgSvg),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Main content
            BlocBuilder<VisitorTvCubit, VisitorTvState>(
              builder: (context, state) {
                if (state is TVDisplayError) {
                  return CustomError(
                    scaleFactor: scaleFactor,
                    currentTime: _currentTime,
                    isRTL: isRTL,
                    state: state,
                  );
                }

                if (state is TVDisplayLoaded) {
                  return Stack(
                    children: [
                      BlocBuilder<LocalizationCubit, LocalizationState>(
                        builder: (context, localizationState) {
                          return TVContent(
                            isRTL: isRTL,
                            currentTime: _currentTime,
                            scaleFactor: scaleFactor,
                            tvState: state,
                            videoUrl: widget.videoUrl,
                          );
                        },
                      ),

                      // Network status indicator
                      if (!state.isNetworkConnected)
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16 * scaleFactor,
                              vertical: 8 * scaleFactor,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.wifi_off,
                                  color: Colors.white,
                                  size: 20 * scaleFactor,
                                ),
                                SizedBox(width: 8 * scaleFactor),
                                Text(
                                  'No Internet Connection',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14 * scaleFactor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                }

                return Column(
                  children: [
                    SizedBox(height: 20),
                    Header(
                      scaleFactor: scaleFactor,
                      currentTime: _currentTime,
                      isRTL: isRTL,
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                              strokeWidth: 4 * scaleFactor,
                            ),
                            SizedBox(height: 24 * scaleFactor),
                            Text(
                              'TV Display is Loading...',
                              style: TextStyle(
                                fontSize: 24 * scaleFactor,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 70 * scaleFactor),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
