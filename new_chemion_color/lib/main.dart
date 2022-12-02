import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(GetMaterialApp(
    initialBinding: PreviewBinding(),
    initialRoute: Routes.initial,
    getPages: AppPages.pages,
    themeMode: ThemeMode.light,
    debugShowCheckedModeBanner: false,
  ));
}
