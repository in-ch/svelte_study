import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart';
import 'package:new_chemion_color/app/data/enums/enums.dart';

/// 케미온 기기 클래스
class BleDeviceItem {
  String deviceName;
  Peripheral peripheral;
  int rssi;
  String serviceUuid;
  //battery 정보 reply를 받아오면 수정해준다
  var batteryPoint = 99;

  //프라이빗모드
  bool isPrivateDevice = false;
  setPrivateDevice(List<int> body) {
    if (body.isNotEmpty) {
      if (body[0] == 226 &&
          body[1] == 129 &&
          body[2] == 163 &&
          body[3] == 226 &&
          body[4] == 129 &&
          body[5] == 163) {
        isPrivateDevice = true;
      } else {
        isPrivateDevice = false;
      }
    }
  }

  DEVICE_TYPE getDeviceType() {
    return DeviceInfo.getTypeUsingServiceUUid(serviceUuid);
  }

  BleDeviceItem(this.deviceName, this.rssi, this.peripheral, this.serviceUuid);

  //selectedDevices 에서만 쓰는 부분
  bool isUsedDevice = false;
  PeripheralConnectionState state = PeripheralConnectionState.disconnected;

  DEVICE_TYPE getDeviceTypeFromUUID() {
    if (serviceUuid == DeviceInfo.uuid_color_service) {
      return DEVICE_TYPE.TYPE_COLOR;
    } else if (serviceUuid == DeviceInfo.uuid_original_service) {
      return DEVICE_TYPE.TYPE_ORIGINAL;
    } else if (serviceUuid == DeviceInfo.uuid_hat_service) {
      return DEVICE_TYPE.TYPE_HAT;
    } else {
      return DEVICE_TYPE.TYPE_COLOR;
    }
  }

  String getDeviceTypeStr() {
    try {
      DEVICE_TYPE type = DeviceInfo.getTypeByDeviceUUID(serviceUuid);
      if (type == DEVICE_TYPE.TYPE_ORIGINAL) {
        return "CHEMION ORIGINAL";
      } else if (type == DEVICE_TYPE.TYPE_COLOR) {
        return "CHEMION COLOR";
      } else if (type == DEVICE_TYPE.TYPE_HAT) {
        return "CHEMION HAT";
      }
      return "CHEMION COLOR";
    } catch (e) {
      return "CHEMION COLOR";
    }
  }

  static int getRowSize(DEVICE_TYPE type) {
    return [24, 24, 32][BleDeviceItem.getDeviceTypeIndex(type)];
  }

  static int getColumnSize(DEVICE_TYPE type) {
    return [9, 9, 12][BleDeviceItem.getDeviceTypeIndex(type)];
  }

  static int TYPE_ORIGINAL_INDEX = 0;
  static int TYPE_COLOR_INDEX = 1;
  static int TYPE_HAT_INDEX = 2;

  static int getDeviceTypeIndex(DEVICE_TYPE type) {
    if (type == DEVICE_TYPE.TYPE_ORIGINAL) {
      return TYPE_ORIGINAL_INDEX;
    } else if (type == DEVICE_TYPE.TYPE_COLOR) {
      return TYPE_COLOR_INDEX;
    } else if (type == DEVICE_TYPE.TYPE_HAT) {
      return TYPE_HAT_INDEX;
    } else {
      return TYPE_COLOR_INDEX;
    }
  }
}
