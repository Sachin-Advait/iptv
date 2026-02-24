import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:oman_tv/configs/lang/localization_cubit.dart';
import 'package:oman_tv/modules/dashboard/cubit/dashboard_cubit.dart';
import 'package:oman_tv/modules/meeting_tv/bloc/meeting_tv_bloc.dart';
import 'package:oman_tv/modules/meeting_tv/repository/meeting_tv_repo.dart';
import 'package:oman_tv/modules/splash/bloc/splash_bloc.dart';
import 'package:oman_tv/modules/visitor_tv/cubit/visitor_tv_cubit.dart';
import 'package:oman_tv/modules/visitor_tv/repo/visitor_tv_repo.dart';
import 'package:oman_tv/services/api_client.dart';
import 'package:oman_tv/services/connectivity_service.dart';
import 'package:oman_tv/services/google_speech.dart';

final getIt = GetIt.instance;

void getItSetup() {
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (kDebugMode) {
          if (options.data is FormData) {
            FormData d = options.data;
            d.fields.forEach(
              ((field) => debugPrint('Fields: ${field.key}: ${field.value}')),
            );
            for (var field in d.files) {
              debugPrint(
                'Files: ${field.key}: ${field.value.filename} ${field.value.contentType?.mimeType}',
              );
            }
          }
        }
        return handler.next(options);
      },
    ),
  );

  // Add logging interceptor with debug check.
  dio.interceptors.add(
    LogInterceptor(
      request: kDebugMode,
      error: kDebugMode,
      responseHeader: kDebugMode,
      requestBody: kDebugMode,
      requestHeader: kDebugMode,
      responseBody: kDebugMode,
    ),
  );

  getIt.registerSingleton<ApiClient>(ApiClient(dio: dio));

  getIt.registerFactory<DashboardCubit>(() => DashboardCubit());

  getIt.registerFactory<SplashBloc>(
    () => SplashBloc()..add(NavigateToNextEvent()),
  );

  getIt.registerFactory<LocalizationCubit>(() => LocalizationCubit());

  getIt.registerLazySingleton<VisitorTvRepo>(
    () => VisitorTvRepo(getIt<ApiClient>()),
  );

  getIt.registerFactory<VisitorTvCubit>(
    () => VisitorTvCubit(getIt<VisitorTvRepo>(), PiperTtsService()),
  );

  getIt.registerFactory<MeetingTvRepo>(() => MeetingTvRepo());

  getIt.registerFactory<MeetingTvBloc>(
    () => MeetingTvBloc(meetingTvRepo: getIt<MeetingTvRepo>()),
  );
}

void resetGetIt() {
  getIt.reset(dispose: false);
  getItSetup();
}
