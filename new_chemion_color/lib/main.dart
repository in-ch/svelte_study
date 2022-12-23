// ignore_for_file: unused_field

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

import 'package:new_chemion_color/app/data/services/app_config/service.dart';
import 'package:new_chemion_color/app/modules/preview/binding.dart';
import 'package:new_chemion_color/routes/pages.dart';

void main() async {
  await mainInit();
}

Future<void> mainInit() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Get.putAsync(() => AppConfigService().init());
  await EasyLocalization.ensureInitialized();

  // 화면 회전 막음.
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runZonedGuarded(() {
    runApp(EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('ko', 'KR')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        child: Phoenix(child: const ChemionApp())));
  }, (error, stack) => debugPrint(error.toString()));
  // (error, stack) => FirebaseCrashlytics.instance.recordError(
  //       error,
  //       stack,
  //       fatal: true,
  //     ));
}

/// 케미온 메인 앱
class ChemionApp extends StatefulWidget {
  const ChemionApp({Key? key}) : super(key: key);

  @override
  State<ChemionApp> createState() => _ChemionAppState();
}

class _ChemionAppState extends State<ChemionApp> {
  /// 인터넷 연결 확인
  final ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: PreviewBinding(),
      initialRoute: Routes.initial,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      getPages: AppPages.pages,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
    );
  }
}
