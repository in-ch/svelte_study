import 'package:flutter/material.dart';

import 'package:new_chemion_color/app/data/enums/enums.dart';
import 'package:new_chemion_color/app/data/models/models.dart';

class FrameData {
  List<int> data = [];
  int frameSpeed = FramesBaseData.DEFAULT_FRAME_SPEED;
  FrameData({
    this.frameSpeed = FramesBaseData.DEFAULT_FRAME_SPEED,
    required this.data,
  });

  LedsData getLedsData() {
    return LedsData(data, frameSpeed: frameSpeed);
  }

  /// 입력받은 프레임의 특정 위치에 색을 추가해서 프레임을 리턴
  FrameData createModifiedFrame(FrameData frame, int ledPosition, Color color) {
    if (getDeviceType() == DEVICE_TYPE.TYPE_ORIGINAL) {
      /// 일반기기는 1byte 당 2LED 1개당 0000 -> 0, 1111 1111 -> 255 0011 0000 -> 95
      /// 오리지널은 1바이트당 4개 묶음 0~255
      // frame.data[(ledPosition ~/ 4)] = 255;
      int intVal = frame.data[(ledPosition ~/ 4)];
      var led = <int>[];
      var first = intVal ~/ 16; //0~15
      var second = intVal % 16; //0~15
      led.add(first ~/ 4); //led 0 (0~3)
      led.add(first % 4); //led 1 (0~3)
      led.add(second ~/ 4); //led 2 (0~3)
      led.add(second % 4); //led 3 (0~3)
      int intColor = getColorByteInt(getDeviceType(), color);
      led[ledPosition % 4] = intColor;
      first = led[0] * 4 + led[1];
      second = led[2] * 4 + led[3];
      frame.data[(ledPosition ~/ 4)] = first * 16 + second;
    } else if (getDeviceType() == DEVICE_TYPE.TYPE_COLOR) {
      /// 컬러는 1LED당 4바이트 1개 묶음 0xFF(R)FF(G)FF(B)FF(A or Brightness)
      /// 수정을 하면 LED에서 바로 수정하면 됨
      String radixStr = color.value.toRadixString(16);
      List<int> led = [
        frame.data[4 * ledPosition],
        frame.data[4 * ledPosition + 1],
        frame.data[4 * ledPosition + 2],
        frame.data[4 * ledPosition + 3]
      ];
      frame.data[4 * ledPosition] = color.red;
      frame.data[4 * ledPosition + 1] = color.green;
      frame.data[4 * ledPosition + 2] = color.blue;

      ///todo 밝기는 기존 Preview에서 설정을 했어서 이부분 처리 고민 필요
      frame.data[4 * ledPosition + 3] = color.alpha;
    }
    return frame;
  }

  /// 컬러를 프레임에 맞는 바이트 값으로 전환
  int getColorByteInt(DEVICE_TYPE type, Color currentDiyColor) {
    if (type == DEVICE_TYPE.TYPE_ORIGINAL) {
      if (currentDiyColor == Colors.white) {
        return 3;
      } else if (currentDiyColor == const Color(0xff767679)) {
        return 2;
      } else if (currentDiyColor == const Color(0xff47474C)) {
        return 1;
      } else {
        return 0;
      }
    } else {
      var color =
          "${currentDiyColor.red.toRadixString(16)}${currentDiyColor.green.toRadixString(16)}${currentDiyColor.blue.toRadixString(16)}${currentDiyColor.alpha.toRadixString(16)}";
      return int.parse(color, radix: 16);
    }
  }

  DEVICE_TYPE getDeviceType() {
    if (data.length == 54) {
      return DEVICE_TYPE.TYPE_ORIGINAL;
    } else if (data.length == 864) {
      return DEVICE_TYPE.TYPE_COLOR;
    } else if (data.length == 1536) {
      return DEVICE_TYPE.TYPE_HAT;
    } else {
      return DEVICE_TYPE.TYPE_COLOR;
    }
  }
}
