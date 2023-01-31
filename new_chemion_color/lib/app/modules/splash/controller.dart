import 'package:get/get.dart';

import 'package:new_chemion_color/app/modules/splash/repository.dart';
import 'package:new_chemion_color/app/data/services/app_config/service.dart';

class SplashController extends GetxController {
  final SplashRepository repository;
  SplashController(this.repository);
  AppConfigService? config;

  final darkMode = false.obs;

  @override
  void onInit() {
    config = Get.find<AppConfigService>();
    darkMode.value = false;
    super.onInit();
  }

  @override
  void dispose() {
    //종료시 블루투스 스캔 종료
    config?.stopBleScan();
    super.dispose();
  }
}
