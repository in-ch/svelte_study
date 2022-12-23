import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:new_chemion_color/app/data/enums/enums.dart';
import 'package:new_chemion_color/app/data/models/models.dart';
import 'package:new_chemion_color/core/theme/app_colors.dart';

/// 오리지널의 경우
/// 9*24 크기의 LED 를 사용하고 있으며, structure 의 크기는 54byte
/// 4led 가 1byte
/// 1byte당 4led     00 01 10 11  |  0 1 2 3
///
/// 컬러의 경우
/// 9*24 864 byte
/// 1led가 4byte     Red 0x00~ 0xff Green 0x00~0xff Blue  0x00~0xff Brightness  0x00~0xff
///                 ex      34             54             22                  12
class LedsData {
  DEVICE_TYPE type = DEVICE_TYPE.TYPE_COLOR;
  List<LedData> leds = <LedData>[];
  int frameSpeed = FramesBaseData.DEFAULT_FRAME_SPEED;

  LedsData(List<int> frameData,
      {this.frameSpeed = FramesBaseData.DEFAULT_FRAME_SPEED}) {
    if (frameData.length == 54) {
      // 54 byte
      type = DEVICE_TYPE.TYPE_ORIGINAL;
    } else if (frameData.length == 864) {
      // 864 byte
      type = DEVICE_TYPE.TYPE_COLOR;
    } else {
      type = DEVICE_TYPE.TYPE_HAT;
    }
    leds = ledsFromFrameData(frameData);
  }

  List<LedData> ledsFromFrameData(List<int> frameData) {
    leds.clear();
    // debugPrint("ledsFromFrameData frame (${frameData.length}): ${frameData}");
    if (type == DEVICE_TYPE.TYPE_ORIGINAL) {
      for (var intVal in frameData) {
        //intVal : 0xff    255
        var first = intVal ~/ 16; //0~15
        var second = intVal % 16; //0~15
        leds.add(LedData(type, [first ~/ 4]));
        leds.add(LedData(type, [first % 4]));
        leds.add(LedData(type, [second ~/ 4]));
        leds.add(LedData(type, [second % 4]));
      }
    } else if (type == DEVICE_TYPE.TYPE_COLOR) {
      /// 컬러에서는 864 byte로 이루어져있고 4바이트당 9 * 24 총 216개의 led로 구성
      var list = Uint8List.fromList(frameData);
      List<List<int>> leds = List.generate((list.length ~/ 4), (index) {
        return [
          list[index * 4],
          list[index * 4 + 1],
          list[index * 4 + 2],
          list[index * 4 + 3]
        ];
      });
      for (var led in leds) {
        leds.add(LedData(type, led) as List<int>);
      }
    }
    return leds;
  }

  ///led에서 프레임 데이터를 뽑아온다
  FrameData frameDataFromLed() {
    List<int> intVals = [];
    if (type == DEVICE_TYPE.TYPE_ORIGINAL) {
      for (int i = 0; i < leds.length ~/ 4; i++) {
        // 1바이트에 들어가는 각 LED 값
        List<int> ledsByteGroup = [
          leds[i * 4].originalData,
          leds[i * 4 + 1].originalData,
          leds[i * 4 + 2].originalData,
          leds[i * 4 + 3].originalData,
        ];
        int byte = ledsByteGroup[0] * 16 * 4 +
            ledsByteGroup[1] * 16 +
            ledsByteGroup[2] * 4 +
            ledsByteGroup[3];
        intVals.add(byte);
      }
    } else if (type == DEVICE_TYPE.TYPE_COLOR) {
      //rgba 4개씩 묶인것을 하나의 리스트로 만들어서 생성

      for (var led in leds) {
        intVals.addAll([led.r, led.g, led.b, led.a]);
      }
    }
    return FrameData(data: intVals);
  }

  /// LED를 움직이고, 움직인 Frame 데이터를 돌려준다
  /// left  의 경우 width size(ex 24 or 32) 가장 왼쪽을 하나 없애고, 가장 오른쪽에 빈 led 추가를  height size 만큼 반복
  /// right 의 경우 가장 오른쪽을 삭제한 후에, 가장 왼쪽에 빈 led 추가
  /// top   의 경우 가장 윗줄 쟝소 size만큼 삭제 후, 가장 마지막에 빈 줄을 추가
  /// bottom의 경우 가장 마지막줄을 삭제 후, 가장 처음에 빈 줄을 추가
  moveLed(DIY_CONTROL_TYPE direction) {
    int rowSize = FramesBaseData.getDeviceFrameRowSizes(type); //9, 12
    int columnSize = FramesBaseData.getDeviceFrameColumnSizes(type); //24, 36

    if (direction == DIY_CONTROL_TYPE.TYPE_MOVE_LEFT) {
      for (int i = 0; i < rowSize; i++) {
        leds.removeAt(i * columnSize);
        leds.insert((((i + 1) * columnSize) - 1), LedData.getEmptyLed((type)));
      }
    } else if (direction == DIY_CONTROL_TYPE.TYPE_MOVE_RIGHT) {
      for (int i = 0; i < rowSize; i++) {
        leds.removeAt((((i + 1) * columnSize) - 1));
        leds.insert(i * columnSize, LedData.getEmptyLed((type)));
      }
    } else if (direction == DIY_CONTROL_TYPE.TYPE_MOVE_TOP) {
      leds.removeRange(0, (columnSize));
      leds.addAll(
          List.generate(columnSize, (index) => LedData.getEmptyLed((type))));
    } else if (direction == DIY_CONTROL_TYPE.TYPE_MOVE_BOTTOM) {
      leds.removeRange(leds.length - columnSize, leds.length);
      leds.insertAll(
          0, List.generate(columnSize, (index) => LedData.getEmptyLed((type))));
    }
  }
}

class LedData {
  DEVICE_TYPE type = DEVICE_TYPE.TYPE_COLOR;
  int originalData = 1; //0 1 2 3
  //color 각 파트별
  int r = 0; //0~255
  int g = 0; //0~255
  int b = 0; //0~255
  int a = 0; //brightess

  LedData(this.type, List<int> led) {
    if (type == DEVICE_TYPE.TYPE_ORIGINAL) {
      originalData = led[0];
    } else if (type == DEVICE_TYPE.TYPE_COLOR) {
      r = led[0];
      g = led[1];
      b = led[2];
      a = led[3];
    }
  } //0~255

  List<int> getData() {
    if (type == DEVICE_TYPE.TYPE_ORIGINAL) {
      //00 01 10 11
      return [originalData];
    } else {
      return [r, g, b, a];
    }
  }

  //타입에 맞춘 색상을 돌려준다
  /// 컬러 가져오기
  /// original은 4색
  /// 컬러, 햇은 256색 기
  Color getColor({int brightness = 255}) {
    Color color = Colors.white;
    if (type == DEVICE_TYPE.TYPE_ORIGINAL) {
      // 00 01 10 11
      if (originalData == 0) {
        color = AppColors.colorBackground;
      } else if (originalData == 1) {
        color = const Color(0xff47474C);
      } else if (originalData == 2) {
        color = const Color(0xff767679);
      } else if (originalData == 3) {
        color = Colors.white;
      } else {
        color = AppColors.colorBackground;
      }
    } else if (type == DEVICE_TYPE.TYPE_COLOR) {
      a = brightness;
      color = Color.fromARGB(a, r, g, b);
    } else {
      //todo 햇은 추후 검증필요
      String radix = originalData.toRadixString(16);
      while (radix.length < 6) {
        radix = "0$radix";
      }
      int r = int.parse(radix.substring(0, 2), radix: 16);
      int g = int.parse(radix.substring(2, 4), radix: 16);
      int b = int.parse(radix.substring(4, 6), radix: 16);
      color = Color.fromARGB(brightness, r, g, b);
    }
    // print("getColor: $color");
    return color;
  }

  ///해당 타입의 비어있는 LED 를 가져온다
  static LedData getEmptyLed(DEVICE_TYPE type) {
    var led = type == DEVICE_TYPE.TYPE_ORIGINAL ? [0] : [0, 0, 0, 0];
    return LedData(type, led);
  }
}
