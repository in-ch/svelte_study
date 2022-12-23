// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:new_chemion_color/app/data/enums/enums.dart';

/// 오리지널, 컬러, 햇 장치의 정보
class DeviceInfo {
  //ble service, read, write  uuid
  static const uuid_original_service = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  static const uuid_original_write = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  static const uuid_original_noti = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";

  static final uuid_color_service =
      "71680001-A42B-4677-8E46-3C732FF81BFA".toLowerCase();
  static final uuid_color_write =
      "71680002-A42B-4677-8E46-3C732FF81BFA".toLowerCase();
  static final uuid_color_noti =
      "71680003-A42B-4677-8E46-3C732FF81BFA".toLowerCase();

  // static final uuid_color_service =
  //     "7168D86A-A42B-4677-8E46-3C732FF81BFA".toLowerCase();
  // static final uuid_color_write =
  //     "7168D86B-A42B-4677-8E46-3C732FF81BFA".toLowerCase();
  // static final uuid_color_noti =
  //     "7168D86C-A42B-4677-8E46-3C732FF81BFA".toLowerCase();

  //todo 모자는 별도로 문서 확인 후 추후 추가 처리 필요
  static const uuid_hat_service = "1e400001-b5a3-f393-e0a9-e50e24dcca9e";
  static const uuid_hat_write = "1e400002-b5a3-f393-e0a9-e50e24dcca9e";
  static const uuid_hat_noti = "1e400003-b5a3-f393-e0a9-e50e24dcca9e";
  //todo 모자는 별도로 문서 확인 후 추후 추가 처리 필요

  //전체 서비스 목록, (ble scan시, 케미온 서비스에서 사용하는 uuid 목록을 사용)
  static final List<String> chemionDeviceServiceUUIDs = [
    uuid_original_service,
    uuid_color_service,
    uuid_hat_service
  ];

  String getServiceUuid(DEVICE_TYPE type) {
    if (type == DEVICE_TYPE.TYPE_ORIGINAL) {
      //chemion
      return uuid_original_service;
    } else if (type == DEVICE_TYPE.TYPE_COLOR) {
      //chemion  color
      return uuid_color_service;
    } else if (type == DEVICE_TYPE.TYPE_HAT) {
      //chemion hat
      return uuid_hat_service;
    }
    return uuid_color_service;
  }

  String getWriteUuid(DEVICE_TYPE type) {
    if (type == DEVICE_TYPE.TYPE_ORIGINAL) {
      //chemion
      return uuid_original_write;
    } else if (type == DEVICE_TYPE.TYPE_COLOR) {
      //chemion  color
      return uuid_color_write;
    } else if (type == DEVICE_TYPE.TYPE_HAT) {
      //chemion hat
      return uuid_hat_write;
    } else {
      return uuid_color_write;
    }
  }

  String getNotiUuid(DEVICE_TYPE type) {
    if (type == DEVICE_TYPE.TYPE_ORIGINAL) {
      //chemion
      return uuid_original_noti;
    } else if (type == DEVICE_TYPE.TYPE_COLOR) {
      //chemion  color
      return uuid_color_noti;
    } else if (type == DEVICE_TYPE.TYPE_HAT) {
      //chemion hat
      return uuid_hat_noti;
    }
    return uuid_color_noti;
  }

  static DEVICE_TYPE getTypeByDeviceUUID(String serviceUuid) {
    if (serviceUuid == uuid_original_service) {
      //chemion
      return DEVICE_TYPE.TYPE_ORIGINAL;
    } else if (serviceUuid == uuid_color_service) {
      //chemion
      return DEVICE_TYPE.TYPE_COLOR;
    } else if (serviceUuid == uuid_hat_service) {
      //chemion
      return DEVICE_TYPE.TYPE_HAT;
    }
    return DEVICE_TYPE.TYPE_COLOR;
  }

  ///오리지널 18 비트씩 밖에 한번에 보내지 못함
  ///Hat, Color는 변경 요청 후 MTU 244로 개발 준비중이었으나 -> 202206월 220으로 변경 확인 -> 200변경
  static int getMTU(DEVICE_TYPE deviceMode) {
    if (deviceMode != DEVICE_TYPE.TYPE_ORIGINAL) {
      return 200;
    } else {
      return 18;
    }
  }

  static DEVICE_TYPE getTypeUsingServiceUUid(String deviceServiceUUid) {
    if (deviceServiceUUid.replaceAll("[", "").replaceAll("]", "") ==
        uuid_original_service) {
      return DEVICE_TYPE.TYPE_ORIGINAL;
    } else if (deviceServiceUUid.replaceAll("[", "").replaceAll("]", "") ==
        uuid_color_service) {
      return DEVICE_TYPE.TYPE_COLOR;
    } else if (deviceServiceUUid.replaceAll("[", "").replaceAll("]", "") ==
        uuid_hat_service) {
      return DEVICE_TYPE.TYPE_HAT;
    } else {
      return DEVICE_TYPE.TYPE_COLOR;
    }
  }
}
