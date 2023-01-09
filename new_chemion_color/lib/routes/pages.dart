import 'package:get/get.dart';

import 'package:new_chemion_color/app/modules/splash/binding.dart';
import 'package:new_chemion_color/app/modules/splash/page.dart';

part './routes.dart';

abstract class AppPages {
  static final pages = [
    GetPage(
        name: Routes.initial,
        page: () => const SplashScreen(),
        bindings: [SplashBinding()]),
  ];
}
