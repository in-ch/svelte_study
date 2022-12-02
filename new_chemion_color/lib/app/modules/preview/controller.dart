import 'package:get/get.dart';

import 'package:new_chemion_color/app/data/services/app_config/service.dart';
import 'package:new_chemion_color/app/modules/preview/repository.dart';

class PreviewController extends GetxController with StateMixin {
  final PreviewRepository repository;
  PreviewController(this.repository);
  AppConfigService? config;
  final darkMode = false.obs;

  @override
  void onInit() {
    config = Get.find<AppConfigService>();
    // getFeed();
    super.onInit();
  }

  // getFeed() async {
  //   final response = await repository.getFeeds();
  //   if (verifyresponse(response)) {
  //     change(response, status: RxStatus.error(response.message));
  //     return Get.snackbar('Erro', response.message);
  //   } else {
  //     change(response, status: RxStatus.success());
  //   }
  // }
}
