import 'package:get/get.dart';

import 'package:new_chemion_color/app/data/provider/api.dart';
import 'package:new_chemion_color/app/modules/preview/controller.dart';
import 'package:new_chemion_color/app/modules/preview/repository.dart';

class PreviewBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PreviewController>(
        () => PreviewController(PreviewRepository(MyApi())));
  }
}
