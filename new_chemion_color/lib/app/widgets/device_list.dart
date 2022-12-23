// ignore_for_file: camel_case_types, constant_identifier_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:new_chemion_color/app/data/models/models.dart';
import 'package:new_chemion_color/app/widgets/device_list_item.dart';

enum DEVICE_USED_TYPE {
  TYPE_USED_DEVICE,
  TYPE_NEW_DEVICE,
}

/// 장치 목록
class DeviceList extends StatefulWidget {
  DEVICE_USED_TYPE deviceType = DEVICE_USED_TYPE.TYPE_NEW_DEVICE;

  List<BleDeviceItem> newDeviceList;
  List<BleDeviceItem> usedDeviceList;

  DeviceList(
      {this.deviceType = DEVICE_USED_TYPE.TYPE_NEW_DEVICE,
      required this.newDeviceList,
      required this.usedDeviceList,
      Key? key})
      : super(key: key);

  @override
  DeviceListState createState() => DeviceListState();
}

class DeviceListState extends State<DeviceList> {
  var deviceType = DEVICE_USED_TYPE.TYPE_NEW_DEVICE;
  List<BleDeviceItem> devices = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    deviceType = widget.deviceType;
    if (deviceType == DEVICE_USED_TYPE.TYPE_NEW_DEVICE) {
      devices = widget.newDeviceList;
    } else {
      devices = widget.usedDeviceList;
    }

    return SizedBox(
        height: (devices.length * 88).toDouble(),
        child: ListView(
          children: devices
              .map(
                (device) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.only(left: 32, right: 32),
                    height: 78,
                    child: DeviceListItem(device)),
              )
              .toList(),
        ));
  }
}
