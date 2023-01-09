import 'package:get/get.dart';

import 'package:new_chemion_color/app/data/provider/api.dart';
import 'package:new_chemion_color/app/modules/splash/controller.dart';
import 'package:new_chemion_color/app/modules/splash/repository.dart';

class SplashBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
        () => SplashController(SplashRepository(MyApi())));
  }
}
