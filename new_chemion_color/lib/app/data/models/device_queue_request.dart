import 'dart:typed_data';

import 'package:new_chemion_color/app/data/models/models.dart';

/// DeviceQueue에 저장할 Request 를 관리
class DeviceQueueRequest {
  /// Request Byte List, EX(0xfa, 0x01, .....0x55, 0xa9)
  Uint8List value;
  DeviceQueueRequest(this.value);

  static Uint8List getColorProtocol(int moduleId,
      {int? index, Uint8List? data, int? frameSize = 1}) {
    Uint8List value = Uint8List.fromList([]);
    value = BleColorProtocolBuilder()
        .getProtocol(moduleId, data: data, index: index, frameSize: frameSize);
    return value;
  }

  static DeviceQueueRequest requestDeleteSlot(int slotIndex) {
    Uint8List list = getColorProtocol(BleProtocolBuilder.moduleIdRemoveSlot,
        index: slotIndex);
    return DeviceQueueRequest(list);
  }

  static DeviceQueueRequest requestDataTransferStart(
      int slotIndex, int frameSize) {
    Uint8List list = getColorProtocol(
        BleProtocolBuilder.moduleIdUpdateFrameStart,
        index: slotIndex,
        frameSize: frameSize);
    return DeviceQueueRequest(list);
  }

  static DeviceQueueRequest requestDataTransfer(
      FramesData framesData, int slotIndex, int frameSize) {
    var frameDataWithInterval = framesData.getFramesDataWithInterval();
    var list = getColorProtocol(BleProtocolBuilder.moduleIdUpdateFrame,
        data: frameDataWithInterval, index: slotIndex, frameSize: frameSize);
    return DeviceQueueRequest(list);
  }

  static DeviceQueueRequest requestDataTransferFinish() {
    var list = [0xFA, 0x01, 0x00, 0x03, 0x01, 0x00, 0x0C, 0x0D, 0x55, 0xA9];
    return DeviceQueueRequest(Uint8List.fromList(list));
  }

  static DeviceQueueRequest requestPlaySlot(int slotIndex) {
    Uint8List list =
        getColorProtocol(BleProtocolBuilder.moduleIdPlaySlot, index: slotIndex);

    return DeviceQueueRequest(list);
  }

  static DeviceQueueRequest requestBatteryLevel() {
    Uint8List list = getColorProtocol(BleProtocolBuilder.moduleIdBatteryLevel);
    return DeviceQueueRequest(Uint8List.fromList(list));
  }

  /// 프로토콜 값으롤 장치가 어떤 프로로콜인지 전달
  static String getProtocolTypeString(Uint8List value) {
    String response = "";
    if (value[1] == 1) {
      response = "[REQUEST]|$response";
    } else if (value[1] == 2) {
      response = "[REPLY]  |$response";
    } else if (value[1] == 4) {
      response = "[NOTIFY] |$response";
    } else if (value[1] == 5) {
      response = "[ERROR]  |$response";
    }

    if (value[5] == 0 && value[6] == 11) {
      response = "${response}LED Slot Data transmission - Start";
    } else if (value[5] == 0 && value[6] == 12) {
      response = "${response}LED Slot Data transmission - End";
    } else if (value[5] == 0 && value[6] == 13) {
      response = "${response}LED Slot Data transmission - Send FrameData";
    } else if (value[5] == 0 && value[6] == 10) {
      response = "${response}Play Slot";
    } else if (value[5] == 0 && value[6] == 20) {
      response = "${response}Delete Slot";
    }
    return response;
  }
}
