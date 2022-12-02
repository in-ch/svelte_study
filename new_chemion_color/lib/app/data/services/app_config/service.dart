import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_chemion_color/app/data/provider/api.dart';

import 'package:new_chemion_color/app/data/services/app_config/repository.dart';

class AppConfigService extends GetxService {
  late AppConfigRepository repository;
  late GetStorage box;
  Future<AppConfigService> init() async {
    repository = AppConfigRepository(MyApi());
    box = GetStorage();
    return this;
  }
}
