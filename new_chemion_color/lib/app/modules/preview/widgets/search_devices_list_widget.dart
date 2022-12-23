import 'package:flutter/material.dart';

import 'package:new_chemion_color/app/data/models/models.dart';
import 'package:new_chemion_color/app/modules/preview/widgets/widgets.dart';
import 'package:new_chemion_color/app/widgets/widgets.dart';

/// 검색되는 장비가 있다면 처리한다.
/// 2022-12-23 Seong incheol
Widget searchedDevicesListWidget(
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
        newDeviceList.isEmpty
            ? Container()
            : Container(
                child: buildDeviceListWidget(
                    context,
                    DEVICE_USED_TYPE.TYPE_NEW_DEVICE,
                    newDeviceList,
                    usedDeviceList),
              ),
      ],
    ),
  );
}
