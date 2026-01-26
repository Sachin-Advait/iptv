import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oman_tv/common/constants/app_strings.dart';
import 'package:oman_tv/common/utils/app_screen_util.dart';
import 'package:oman_tv/common/utils/focus_traversal.dart';
import 'package:oman_tv/common/utils/get_it.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/configs/theme/app_theme.dart';
import 'package:oman_tv/modules/dashboard/dashboard_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await ScreenUtil.ensureScreenSize();
  // await WakelockPlus.enable();
  getItSetup();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: AppColors.white,
      systemNavigationBarDividerColor: AppColors.white,
      systemNavigationBarColor: AppColors.white,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _focusNode = RecentFocusNode(group: FocusGroup.root);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ScreenUtilInit(
        designSize: Size(constraints.maxWidth, constraints.maxHeight),
        minTextAdapt: true,
        ensureScreenSize: true,
        splitScreenMode: true,
        builder: (context, child) {
          final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

          AppScreenUtil().init(constraints);

          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(isTablet ? 1.2 : 1.0)),
            child: MaterialApp(
              // routerConfig: Pages.appRouter,
              title: AppStrings.appTitle,
              debugShowCheckedModeBanner: false,
              theme: AppThemes.lightTheme,
              home: WillPopScope(
                onWillPop: _willPopCallback,
                child: Scaffold(
                  body: Focus(
                    focusNode: _focusNode,
                    descendantsAreFocusable: true,
                    child: const DashboardView(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<bool> _willPopCallback() async {
  return false;
}
