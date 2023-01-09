import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get_state_manager/get_state_manager.dart';
// import 'package:get/instance_manager.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:easy_localization/easy_localization.dart';

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
    checkPermissions();
    super.onInit();
  }

  @override
  void dispose() {
    //종료시 블루투스 스캔 종료
    config?.stopBleScan();
    super.dispose();
  }

  checkPermissions() async {
    print("Hello world");
    print("Hello world");
    print("Hello world");
    var permissions = await [
      Permission.location,
      Permission.locationAlways,
      Permission.locationWhenInUse,
      Permission.storage,
    ].request().whenComplete(() async {
      await Future.delayed(const Duration(milliseconds: 500))
          .whenComplete(() async {
        config?.setPermissionStatus(true);
        await config?.startBleScan();
      });
    });
    if (permissions[Permission.location] != PermissionStatus.granted ||
        permissions[Permission.locationWhenInUse] != PermissionStatus.granted) {
      Fluttertoast.showToast(
          // msg: "permission_location".tr(),
          msg: "permission_location",
          backgroundColor: const Color(0xff9254FF),
          textColor: Colors.white,
          fontSize: 15.0,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 4,
          gravity: ToastGravity.BOTTOM);
    }
  }
}
