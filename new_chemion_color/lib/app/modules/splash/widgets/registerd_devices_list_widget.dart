import 'package:flutter/material.dart';

import 'package:new_chemion_color/app/data/models/models.dart';
import 'package:new_chemion_color/app/modules/splash/widgets/widgets.dart';
import 'package:new_chemion_color/app/widgets/widgets.dart';

/// 이미 연결 된 적이 있는 장치가 있으면 처리한다.
/// 2022-12-23 Seong incheol
Widget registeredDevicesListWidget(
    BuildContext context,
    List<BleDeviceItem> devices,
    List<BleDeviceItem> newDeviceList,
    List<BleDeviceItem> usedDeviceList) {
  return SizedBox(
    height: (devices.length * 88).toDouble(),
    width: double.maxFinite,
    child: Column(
      children: [
        //새 장치각 비어있지 않으면 새 장치를 노출
        usedDeviceList.isEmpty
            ? Container()
            : Container(
                child: buildDeviceListWidget(
                    context,
                    DEVICE_USED_TYPE.TYPE_USED_DEVICE,
                    newDeviceList,
                    usedDeviceList),
              ),
      ],
    ),
  );
}
