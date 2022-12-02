import 'package:get/get.dart';

import 'package:new_chemion_color/app/modules/preview/binding.dart';
import 'package:new_chemion_color/app/modules/preview/page.dart';

part './routes.dart';

abstract class AppPages {
  static final pages = [
    GetPage(
        name: Routes.initial,
        page: () => const PreviewScreen(),
        bindings: [PreviewBinding()]),
  ];
}
