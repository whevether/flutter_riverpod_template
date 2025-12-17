import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_template/app/app_style.dart';
import 'package:flutter_riverpod_template/app/log.dart';
import 'package:flutter_riverpod_template/app/utils.dart';
import 'package:flutter_riverpod_template/i18n/localization_intl.dart';
import 'package:flutter_riverpod_template/router/app_router.dart';
import 'package:flutter_riverpod_template/services/app_setting_service.dart';
import 'package:flutter_riverpod_template/services/local_storage_service.dart';
import 'package:flutter_riverpod_template/widget/status/app_loadding_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Hive.initFlutter();
      //设置状态栏为透明
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      );
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
      await initServices();
      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stackTrace) {
      //全局异常
      Log.e(error.toString(), stackTrace);
    },
  );
}

Future initServices() async {
  //包信息
  Utils.packageInfo = await PackageInfo.fromPlatform();
  //本地存储
  Log.d("Init LocalStorage Service");
  await LocalStorageService.instance.init();
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSetting = ref.watch(appSettingProvider);
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp.router(
        title: 'Flutter Riverpod Template',
        scrollBehavior: AppScrollBehavior(),
        themeMode: appSetting.themeMode,
        theme: AppStyle.lightTheme,
        darkTheme: AppStyle.darkTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          LanguageLocalizationsDelegate(),
        ],
        routeInformationProvider:
            AppRouter.instance.router.routeInformationProvider,
        routeInformationParser:
            AppRouter.instance.router.routeInformationParser,
        routerDelegate: AppRouter.instance.router.routerDelegate,
        locale: appSetting.locale,
        supportedLocales: const [
          Locale("zh", "CN"),
          Locale("en", "US"),
          Locale("zh", "HK"),
          Locale("vi", "VN"),
          Locale("th", "TH"),
          Locale("in", "ID"),
          Locale("hi", "IN"),
          Locale("en", "PH"),
          Locale("ms", "MY"),
        ],
        debugShowCheckedModeBanner: false,
        // navigatorObservers: [FlutterSmartDialog.observer],
        builder: FlutterSmartDialog.init(
          loadingBuilder: ((msg) => AppLoaddingWidget(msg: msg)),
          //字体大小不跟随系统变化
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          ),
        ),
      ),
    );
  }
}
