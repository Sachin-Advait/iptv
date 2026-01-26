// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:go_router/go_router.dart';
// import 'package:oman_tv/configs/assets/app_images.dart';
// import 'package:oman_tv/routes/app_pages.dart';

// import '../bloc/splash_bloc.dart';

// class SplashView extends StatelessWidget {
//   const SplashView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocListener<SplashBloc, SplashState>(
//         listener: (_, state) {
//           switch (state) {
//             case SplashInitial():
//             case NavigateToHomeActionState():
//               context.goNamed(Routes.home);

//             case NavigateToLoginActionState():
//               context.goNamed(Routes.home);
//           }
//         },
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 60),
//             child: SvgPicture.asset(AppImages.splashLogo),
//           ),
//         ),
//       ),
//     );
//   }
// }
