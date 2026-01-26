// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:oman_tv/common/utils/get_it.dart';
// import 'package:oman_tv/common/utils/global_keys.dart';
// import 'package:oman_tv/modules/annoucement/annoucement_view.dart';
// import 'package:oman_tv/modules/catch_up/catch_up_view.dart';
// import 'package:oman_tv/modules/dashboard/dashboard_view.dart';
// import 'package:oman_tv/modules/home/home_view.dart';
// import 'package:oman_tv/modules/live_tv/live_tv_view.dart';
// import 'package:oman_tv/modules/radio/radio_view.dart';
// import 'package:oman_tv/modules/splash/bloc/splash_bloc.dart';
// import 'package:oman_tv/modules/splash/view/splash_view.dart';
// import 'package:oman_tv/modules/vod/vod_view.dart';

// part 'app_routes.dart';

// class Pages {
//   static GoRouter get appRouter => _appRouter;

//   static final GoRouter _appRouter = GoRouter(
//     initialLocation: Routes.splash,
//     navigatorKey: GlobalKeys.navigatorKey,
//     routes: [
//       GoRoute(
//         path: Routes.splash,
//         name: Routes.splash,
//         builder: (_, state) => BlocProvider(
//           create: (context) => getIt<SplashBloc>()..add(NavigateToNextEvent()),
//           child: const SplashView(),
//         ),
//       ),
//       StatefulShellRoute.indexedStack(
//         builder: (context, state, navigationShell) {
//           return DashboardView(navigationShell: navigationShell);
//         },
//         branches: [
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: Routes.home,
//                 name: Routes.home,
//                 builder: (_, _) => const HomeView(),
//               ),
//             ],
//           ),
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: Routes.liveTV,
//                 name: Routes.liveTV,
//                 builder: (_, _) => const LiveTVView(),
//               ),
//             ],
//           ),

//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: Routes.vod,
//                 name: Routes.vod,
//                 builder: (_, _) => const VodView(),
//               ),
//             ],
//           ),
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: Routes.catchUp,
//                 name: Routes.catchUp,
//                 builder: (_, _) => const CatchUpView(),
//               ),
//             ],
//           ),
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: Routes.radio,
//                 name: Routes.radio,
//                 builder: (_, _) => const RadioView(),
//               ),
//             ],
//           ),
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: Routes.annoucement,
//                 name: Routes.annoucement,
//                 builder: (_, _) => const AnnouncementView(),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ],
//   );
// }
