import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/connectivity_aware_mixin.dart';
import 'package:oman_tv/configs/assets/app_images.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/routes/app_pages.dart';

import '../bloc/splash_bloc.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with ConnectivityAwareMixin<SplashView> {
  @override
  void onConnectivityRestored() {
    debugPrint('✅ Internet restored, retrying registration...');
    context.read<SplashBloc>().add(NavigateToNextEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc()..add(NavigateToNextEvent()),
      child: Scaffold(
        body: BlocListener<SplashBloc, SplashState>(
          listener: (_, state) {
            switch (state) {
              case SplashInitial():
              case NavigateToHomeActionState():

                // case NavigateToLoginActionState():
                Navigator.pushReplacementNamed(context, Routes.dashboard);
            }
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(AppImages.splashLogo),
                  20.verticalSpace,
                  LoadingAnimationWidget.progressiveDots(
                    color: AppColors.brownDeep,
                    size: 80,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
