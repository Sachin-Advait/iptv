import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oman_tv/common/utils/get_it.dart';
import 'package:oman_tv/common/widgets/video_player.dart';
import 'package:oman_tv/modules/dashboard/dashboard_view.dart';
import 'package:oman_tv/modules/profile/profile_view.dart';
import 'package:oman_tv/modules/splash/bloc/splash_bloc.dart';
import 'package:oman_tv/modules/splash/view/splash_view.dart';

part 'app_routes.dart';

class Pages {
  static MaterialPageRoute _simpleRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(settings: settings, builder: (_) => page);
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return _simpleRoute(
          BlocProvider(
            create: (context) => getIt<SplashBloc>(),
            child: const SplashView(),
          ),
          settings,
        );

      case Routes.dashboard:
        return _simpleRoute(const DashboardView(), settings);

      case Routes.profile:
        return _simpleRoute(const ProfileView(), settings);

      case Routes.video:
        final args = settings.arguments as Map<String, dynamic>?;
        final videoUrl = args?['videoUrl'] as String?;

        return _simpleRoute(
          VideoView(
            videoUrl:
                videoUrl ??
                "https://live.alarabiya.net/alarabiapublish/alarabiya.smil/playlist.m3u8",
          ),
          settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
