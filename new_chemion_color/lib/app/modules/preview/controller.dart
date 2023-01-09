import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:new_chemion_color/app/data/services/app_config/service.dart';
import 'package:new_chemion_color/app/modules/preview/repository.dart';

class PreviewController extends GetxController {
  final PreviewRepository repository;
  PreviewController(this.repository);
  AppConfigService? config;

  @override
  void onInit() async {
    print('START BLE SCAN!!!!!');
    print('START BLE SCAN!!!!!');
    print('START BLE SCAN!!!!!');
    print('START BLE SCAN!!!!!');
    print('START BLE SCAN!!!!!');
    print('START BLE SCAN!!!!!');
    print('START BLE SCAN!!!!!');
    print('START BLE SCAN!!!!!');
    print('START BLE SCAN!!!!!');
    print('START BLE SCAN!!!!!');
    config = Get.find<AppConfigService>();
    checkPermissions();
    super.onInit();
  }

  @override
  void dispose() {
    //종료시 블루투스 스캔 종료
    config?.stopBleScan();
    super.dispose();
  }

  Future<void> checkPermissions() async {
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
          msg: "permission_location".tr(),
          backgroundColor: const Color(0xff9254FF),
          textColor: Colors.white,
          fontSize: 15.0,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 4,
          gravity: ToastGravity.BOTTOM);
    }
  }
}
