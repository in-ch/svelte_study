import 'package:flutter/material.dart';

import 'package:new_chemion_color/app/data/models/models.dart';
import 'package:new_chemion_color/app/widgets/widgets.dart';

Widget buildDeviceListWidget(BuildContext context, DEVICE_USED_TYPE deviceType,
    List<BleDeviceItem> newDeviceList, List<BleDeviceItem> usedDeviceList) {
  return DeviceList(
    deviceType: deviceType,
    newDeviceList: newDeviceList,
    usedDeviceList: usedDeviceList,
  );
}
