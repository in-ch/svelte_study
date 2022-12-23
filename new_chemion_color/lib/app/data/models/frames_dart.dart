// ignore_for_file: unused_import, constant_identifier_names

import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:new_chemion_color/app/data/enums/enums.dart';
import 'package:new_chemion_color/app/data/models/models.dart';

/// 프레임 리스트 데이터 클래스
/// 묶어서 처리했는데 프로토콜이나 여러가지가 달라지게 되어서
/// 오리지널, 컬러 각각 분리해서 개발
abstract class FramesBaseData {
  static const DEFAULT_FRAME_SPEED = 30;
  DEVICE_TYPE type = DEVICE_TYPE.TYPE_COLOR;
  int intervalSize = 1;
  int deviceFrameByteSize = 0; //1프레임 당 사이즈
  int deviceFrameRowSize = 0; //1프레임 당 row 사이즈
  int deviceFrameColumnSize = 0; //1프레임 당 column 사이즈
  int frameSpeed = DEFAULT_FRAME_SPEED; //기본 속도 *10을 한 ms, 30 이면 *10 총 300ms
  int deviceFrame1LineSize = 0; //1줄 당 필요한 bytes
  List<FrameData> frames =
      []; //실제 LED 프레임  List Frame(속도 1byte+ devicdFrameSize)

  // //1줄 당 필요한 bytes
  // //오리지널은 4led당 1byte(24 / 4 = 6 byte)
  // static List<int> deviceFrame1LineSizes = [6, 96, 144];
  // static List<int> deviceFrame1LineSizes = [6, 24*4, 36]; // 24/4, 24*4, ?

  //1프레임 당 사이즈 original / color / hat
  static int getDeviceFrameByteSizes(DEVICE_TYPE type) {
    return [54, 864, 1536][BleDeviceItem.getDeviceTypeIndex(type)];
  }

  //1프레임 당 row 사이즈 original / color / hat
  static int getDeviceFrameRowSizes(DEVICE_TYPE type) {
    return [9, 9, 12][BleDeviceItem.getDeviceTypeIndex(type)];
  }

  //1프레임 당 column 사이즈 original / color / hat
  static int getDeviceFrameColumnSizes(DEVICE_TYPE type) {
    return [24, 24, 36][BleDeviceItem.getDeviceTypeIndex(type)];
  }

  //방향키, 반전, 직접 그리기,  붙여넣기, 지우기, 휴지통 시에 직전 기록 기억
  List<List<FrameData>> histories = []; //히스토리 목록
  List<int> historyCursors = []; // 히스토리 커서

  //총 프레임 장수 전달
  int getFramesSize() {
    return frames.length;
  }

  //프레임 목록을 가져온다
  List<FrameData> getFrames() {
    return frames;
  }

  FrameData getFrame(int position) {
    return frames[position];
  }

  //기기타입에 따른 기본 빈 프레임 1개 리턴
  static FrameData getEmptyBaseFrame(DEVICE_TYPE type,
      {int frameIntervalMS = FramesBaseData.DEFAULT_FRAME_SPEED}) {
    //1속도 + 기기 타입별 프레임
    var speed = frameIntervalMS;
    var frameData = <int>[];
    frameData
        .addAll(List.generate((getDeviceFrameByteSizes(type)), (index) => 0));
    return FrameData(frameSpeed: speed, data: frameData);
  }

  //기기타입에 따른 기본 빈 프레임 1개를 포함한 프레임 목록 리턴
  static FramesData getEmptyBaseFrames(DEVICE_TYPE type,
      {int frameIntervalMS = FramesBaseData.DEFAULT_FRAME_SPEED}) {
    return FramesData(type);
  }

  //선택 된 프레임을 리셋처리
  void resetFrame(int frameIndex) {
    FrameData emptyFrame = getEmptyBaseFrame(type, frameIntervalMS: frameSpeed);
    frames[frameIndex] = emptyFrame;
    addHistory(frameIndex);
  }

  /// 프레임 스피드 변경
  void updateFrameSpeed(int speed) {
    // todo 컬러에서 속도 규격 체크
    if (speed < 1) {
      speed = 1;
    } else if (speed > 255) {
      speed = 255;
    }
    frameSpeed = speed;
  }

  /// 현재 프레임인덱스 다음 위치엥 처음 히스토리 공간을 만들어준다
  void addHistoryBox(int frameIndex) {
    histories.insert(frameIndex, []);
    historyCursors.insert(frameIndex, -1);
  }

  /// 현재 프레임을 히스토리에 추가한다
  void addHistory(int frameIndex) {
    if (histories[frameIndex].isEmpty) {
      histories[frameIndex] = [
        FrameData(data: List.from(frames[frameIndex].data))
      ];
    } else {
      histories[frameIndex]
          .add(FrameData(data: List.from(frames[frameIndex].data)));
    }
    historyCursors[frameIndex] += 1;
  }
}

class FramesData extends FramesBaseData {
  FramesData(DEVICE_TYPE? type, {FrameData? initFrameData}) {
    this.type = type ??= DEVICE_TYPE.TYPE_COLOR;
    initFrames(initFrameData);
  }

  int getFrameIntervalMS() {
    return frameSpeed;
  }

  // 현재 프레임 다음 위치 비어있는 프레임을 추가
  Future<void> addEmptyFrame(DEVICE_TYPE type, int currentDiyFrameIndex) async {
    var length = getFramesSize();
    if (length > 19) {
      Fluttertoast.showToast(
          msg: "frame_limit".tr(),
          backgroundColor: const Color(0xff9254FF),
          textColor: Colors.white,
          fontSize: 15.0,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          gravity: ToastGravity.BOTTOM);
    } else {
      FrameData emptyFrame = FramesBaseData.getEmptyBaseFrame(type,
          frameIntervalMS: getFrameIntervalMS());
      addHistoryBox(currentDiyFrameIndex);
      addHistory(currentDiyFrameIndex);
      frames.insert(currentDiyFrameIndex + 1, emptyFrame);
    }

    return;
  }

  /// 현재 프레임을 삭제한다
  /// 프레임 숫자가 1이면 초기
  void deleteFrame(int frameIndex) {
    frames.removeAt(frameIndex);
    histories.removeAt(frameIndex);
    historyCursors.removeAt(frameIndex);
  }

  /// LED를 특정 방향으로 이동
  /// 이후 해당 LED값을 적용한 프레임 기록
  void moveLed(int frameIndex, DIY_CONTROL_TYPE direction) {
    LedsData leds = LedsData(getFrame(frameIndex).data);
    leds.moveLed(direction);
    FrameData movedFrame = leds.frameDataFromLed();
    frames[frameIndex].data = List.from(movedFrame.data);
    addHistory(frameIndex);
  }

  ///프레임을 반전한다. 오리지널은 0,1,2,3 색상이고 컬러는 argb 형태이다
  void reverseFrame(int frameIndex) {
    if (type == DEVICE_TYPE.TYPE_ORIGINAL) {
      for (int i = 0; i < frames[frameIndex].data.length; i++) {
        frames[frameIndex].data[i] = 255 - frames[frameIndex].data[i];
      }
    } else {
      //컬러, 햇
      for (int i = 0; i < frames[frameIndex].data.length; i++) {
        frames[frameIndex].data[i] =
            (16777215 - frames[frameIndex].data[i]).abs();
      }
    }
    addHistory(frameIndex);
  }

  ///한장의 ledFrame을 list<int>로 가져온다
  LedsData getLedsData(int i) {
    try {
      return frames[i].getLedsData();
    } catch (e) {
      return LedsData(FramesBaseData.getEmptyBaseFrame(type).data);
    }
  }

  //size에 맞추어서 chunk 처리
  static List chunk(List list, int chunkSize) {
    List chunks = [];
    int len = list.length;
    for (var i = 0; i < len; i += chunkSize) {
      int size = i + chunkSize;
      chunks.add(list.sublist(i, size > len ? len : size));
    }
    return chunks;
  }

  //frame x, width size
  int getXSize() {
    if (type == DEVICE_TYPE.TYPE_HAT) {
      return 36;
    } else {
      return 24;
    }
  }

  //frame y, height size
  int getYSize() {
    if (type == DEVICE_TYPE.TYPE_HAT) {
      return 12;
    } else {
      return 9;
    }
  }

  //전체 데이터 초기값 설정
  void initFrames(FrameData? initFramesData) {
    histories.clear();
    historyCursors.clear();
    frames.clear();

    if (initFramesData == null) {
      FrameData emptyFrame = FramesBaseData.getEmptyBaseFrame(type,
          frameIntervalMS: getFrameIntervalMS());
      frames.add(emptyFrame);
    } else {
      frames.add(initFramesData);
    }
    addHistoryBox(0);
    addHistory(0);
  }

  /// 프레임과, led를 실시간 업데이트
  void updateFrame(int currentFrameIndex, int ledPosition, Color color) {
    FrameData frame = frames[currentFrameIndex]
        .createModifiedFrame(frames[currentFrameIndex], ledPosition, color);
    frames[currentFrameIndex] = frame;
  }

  /// 복사된 프레임 붙여넣고 추가
  void pasteFrame(int currentDiyFrameIndex, FrameData copiedFrame) {
    FrameData frame = FrameData(data: List.from(copiedFrame.data));
    frames[currentDiyFrameIndex] = frame;
  }

  /// 해당 프레임의 히스토리 커서를 변경한다
  FrameData moveHistoryCursor(int frameIndex, MOVE_HISTORY_TYPE sType) {
    if (sType == MOVE_HISTORY_TYPE.TYPE_BACK) {
      // back 이동
      if (histories[frameIndex].isNotEmpty && historyCursors[frameIndex] > 0) {
        historyCursors[frameIndex] -= 1;
        var frame = histories[frameIndex][historyCursors[frameIndex]];
        frames[frameIndex] = frame;
      }
    } else if (sType == MOVE_HISTORY_TYPE.TYPE_FORWARD) {
      // front 이동
      if (histories[frameIndex].isNotEmpty &&
          historyCursors[frameIndex] < histories[frameIndex].length - 1) {
        historyCursors[frameIndex] += 1;
        var frame = histories[frameIndex][historyCursors[frameIndex]];
        frames[frameIndex] = frame;
      }
    }
    return histories[frameIndex][historyCursors[frameIndex]];
  }

  //프레임 데이터를 list<int>형으로 가져옴
  List<int> getFramesToList() {
    List<int> list = [];
    for (var frame in frames) {
      list.addAll(frame.data);
    }
    return list;
  }

  int getLEDSize() {
    return getXSize() * getYSize();
  }

  /// 특정 인덱스의 프레임 데이터 리턴
  List<int> getFrameData(int index) {
    return frames[index].data;
  }

  /// 속도(interval) + 데이터 리스트를 리턴해준다
  /// 오리지널의 경우는 프레임 숫자만큼 프로토콜 요청을  n 회 계속 보내기 때문에 frameIndex를 넣어서
  /// 해당 frameIndex의 프레임만 담아서 전송하고
  /// 컬러의 경우는 프레임 숫자 + (속도(interval) + 데이터)목록 을 한번에 보내주는데
  /// 여기에서는 frameIndex를 넣지 않은 경우에는 프레임 숫자를 제외한 속도(interval) + 데이터 목록을 전달

  /// 오리지널 55   interval 1 + 54조각    54 byte     n 프레임이 있어도 1개씩 n번 전송
  /// 컬러    217  interval 1 + 216조각   864 /4 byte n 프레임이 있으면 n개를 1회에 전송
  /// 햇(미정)   예측::  385  interval 1 + 384조각    1536 byte
  Uint8List getFramesDataWithInterval({int? frameIndex}) {
    List<int> list = [];
    if (frameIndex == null) {
      getFrames().forEach((frame) {
        list.addAll([frameSpeed, ...frame.data]);
      });
    } else {
      list.addAll([frameSpeed, ...getFrames()[frameIndex - 1].data]);
    }
    return Uint8List.fromList(list);
  }

  ///프레임 데이터를 추가한다
  void addFrame(FrameData frameData) {
    frames.add(frameData);
  }
}

class FramesDataBluePrint {
  static List chunk(List list, int chunkSize) {
    List chunks = [];
    int len = list.length;
    for (var i = 0; i < len; i += chunkSize) {
      int size = i + chunkSize;
      chunks.add(list.sublist(i, size > len ? len : size));
    }
    return chunks;
  }

  //청사진 텍스트 구조에서 기기별 프레임으로 전환
  //[1,0,0,1, ...]
  //[1 0 0 1,....]
  //9x24 속도, 색상, 밝기 없는 단순 청사진에 텍스트용 speed, bright처리
  static FramesData blueprintTextToFrames(
      DEVICE_TYPE deviceType, int brightness, List<List<int>> blueprint) {
    int frameIntervalMS = 30;
    int frameColumnSize = 24;

    //빈공간 1번 추가
    for (var row in blueprint) {
      var dummy = <int>[];
      dummy.addAll(
          List.generate(BleDeviceItem.getRowSize(deviceType), (index) => 0));
      row.addAll(dummy);
    }
    String brightness = "11";

    FramesData framesData = FramesData(deviceType);
    final BuildContext? context =
        ChemionGlobalVariable.naviagatorState.currentContext;
    // String color = context!
    //     .read<MainProvider>()
    //     .diyDrawFrameData
    //     .currentDiyColor
    //     .toString()
    //     .substring(10, 16);
    String color = '#00ffff';

    framesData.frames = [];
    // 24 width면 24장, 25width면 25장 생성
    // var newFrameSize = (blueprint[0].length + 1) - frameColumnSize;
    var newFrameSize = 19;
    for (int frameIndex = 0; frameIndex < newFrameSize; frameIndex++) {
      FrameData frame = FramesBaseData.getEmptyBaseFrame(deviceType);
      List<List<int>> dataList = [];
      // 54 int list 생성 (9 * 24  총216 led 4개당 1 int값)
      //9번  또는 12번 row 숫자만큼 반복
      for (int rowIndex = 0; rowIndex < blueprint.length; rowIndex++) {
        //24자리 전체 청사진에서 잘라옴
        // var row = blueprint[rowIndex].sublist(frameIndex, frameIndex+24);
        dynamic row = blueprint[rowIndex].sublist(frameIndex, frameIndex + 24);
        dataList.addAll(List.generate(
            row.length,
            (index) => [
                  row[index] == 1
                      ? int.parse(color.substring(0, 2), radix: 16)
                      : row[index] * brightness,
                  row[index] == 1
                      ? int.parse(color.substring(2, 4), radix: 16)
                      : row[index] * brightness,
                  row[index] == 1
                      ? int.parse(color.substring(4, 6), radix: 16)
                      : row[index] * brightness,
                  row[index] * brightness
                ]));
      }
      frame.data = <int>[];
      for (var list in dataList) {
        frame.data.addAll(list);
      }
      framesData.addFrame(frame);
    }
    return framesData;
  }

  //1장만 만들어서 리턴
  static FramesData blueprintTextToFrame(
      DEVICE_TYPE deviceType, int brightness, List<List<int>> blueprint) {
    FramesData frameData =
        blueprintTextToFrames(deviceType, brightness, blueprint);
    return FramesData(deviceType, initFrameData: frameData.getFrames()[0]);
  }

  //움직이는 텍스트 프레임 청사진
  static FramesData blueprintMoveTextToFrames(
      DEVICE_TYPE deviceType, int brightness, List<List<int>> blueprint) {
    FramesData framesData =
        blueprintTextToFrames(deviceType, brightness, blueprint);

    ///첫장 포함한 프레임 데이터 생성
    FramesData movingFramesData =
        FramesData(deviceType, initFrameData: framesData.getFrames()[0]);
    List<FrameData> getFrame = framesData.getFrames();

    for (int i = 0; i < getFrame.length; i++) {
      FrameData frameData = getFrame[i];
      if (i % 8 == 0) {
      } else if (i % 8 == 1) {
        frameData = getMovingFrame(
            frameData, deviceType, DIY_CONTROL_TYPE.TYPE_MOVE_TOP);
      } else if (i % 8 == 2) {
        // frameData = getMovingFrame(
        //     frameData, deviceType, DIY_CONTROL_TYPE.TYPE_MOVE_TOP);
        // frameData = getMovingFrame(
        //     frameData, deviceType, DIY_CONTROL_TYPE.TYPE_MOVE_TOP);
      } else if (i % 8 == 3) {
        frameData = getMovingFrame(
            frameData, deviceType, DIY_CONTROL_TYPE.TYPE_MOVE_TOP);
        frameData = getMovingFrame(
            frameData, deviceType, DIY_CONTROL_TYPE.TYPE_MOVE_TOP);
        // frameData = getMovingFrame(
        //     frameData, deviceType, DIY_CONTROL_TYPE.TYPE_MOVE_TOP);
      } else if (i % 8 == 4) {
        // frameData = getMovingFrame(
        //     frameData, deviceType, DIY_CONTROL_TYPE.TYPE_MOVE_TOP);
        // frameData = getMovingFrame(
        //     frameData, deviceType, DIY_CONTROL_TYPE.TYPE_MOVE_TOP);
        // frameData = getMovingFrame(
        //     frameData, deviceType, DIY_CONTROL_TYPE.TYPE_MOVE_TOP);
      } else if (i % 8 == 5) {
        frameData = getMovingFrame(
            frameData, deviceType, DIY_CONTROL_TYPE.TYPE_MOVE_TOP);
        frameData = getMovingFrame(
            frameData, deviceType, DIY_CONTROL_TYPE.TYPE_MOVE_TOP);
      } else if (i % 8 == 6) {
        // frameData = getMovingFrame(
        //     frameData, deviceType, DIY_CONTROL_TYPE.TYPE_MOVE_TOP);
      } else if (i % 8 == 7) {}
      movingFramesData.addFrame(frameData);
    }

    return movingFramesData;
  }

  //움직이는 프레임(텍스트)
  static FrameData getMovingFrame(
      FrameData frameData, DEVICE_TYPE deviceType, DIY_CONTROL_TYPE direction) {
    LedsData leds = LedsData(
      frameData.data,
    );
    leds.moveLed(direction);
    FrameData movedFrame = leds.frameDataFromLed();
    return movedFrame;
  }
}
