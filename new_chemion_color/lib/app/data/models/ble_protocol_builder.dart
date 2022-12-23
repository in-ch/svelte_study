import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import 'package:new_chemion_color/app/data/models/models.dart';

/// 케미온 블루투스 프로토콜을 생성
abstract class BleProtocolBuilder {
  // 공용 프로토콜 메세지 헥스값
  static const Map<String, int> msgIdType = {
    "request": 0x01,
    "reply": 0x02,
    "stream": 0x03,
    "notify": 0x04,
    "error": 0x05,
    "identify": 0x06
  };

  // 공용 메세지 타입 선언
  static int moduleIdBatteryLevel = 0x0003;
  static int moduleIdSetDeviceState = 0x0004;

  static int moduleIdUpdateFrameStart = 0x000B;
  static int moduleIdUpdateFrameFinish = 0x000C;
  static int moduleIdUpdateFrame = 0x000D;

  static int moduleIdPlaySlot = 0x0010;
  static int moduleIdRemoveSlot = 0x0014;

  ///프로토콜 데이터 요청
  Uint8List getProtocol(int typeValue,
      {int? index, Uint8List? data, int? frameSize});

  ///msgId, payload 기준으로 프로토콜 데이터 생성
  Uint8List _buildProtocolData(int type, {int? index, Uint8List? data});

  // 프로토콜의 payload 부분을 생성
  List<int> _buildPayload(int type,
      {int? index, Uint8List? data, int? frameSize = 1});

  //모듈 아이디 2자리수로 분리
  List<int> _buildModuleId(int moduleId);

  //실시간 프레임 스트림 프로토콜 가져오는 함수(getProtocol 과 유사)
  Uint8List getRealtimeStartProtocol(FramesData framesData);

  //실시간 프레임 종료 프로토콜 가져오는 함수
  Uint8List getRealtimFinishProtocol();

  //payload 길이 체크, 0x00 0x00 2자리 65520크기까지 가질 수 있다
  List<int> checkPayloadLength(List<int> payload) {
    List<int> lens = [];
    lens.add(payload.length ~/ 256); //0x00 1번자리
    lens.add(payload.length % 256); //0x00 2번자리
    return lens;
  }
}

/// 오리지널 전용 프로토콜 빌더
class BleOriginalProtocolBuilder extends BleProtocolBuilder {
  static int moduleIdStreamFrameFinish = 0x0005;
  static int moduleIdStreamFrameStart = 0x0006;

  // 메세지 아이디
  Map<int, int> msgIds = {
    BleProtocolBuilder.moduleIdSetDeviceState:
        BleProtocolBuilder.msgIdType["request"]!,
    BleProtocolBuilder.moduleIdBatteryLevel:
        BleProtocolBuilder.msgIdType["request"]!,
    BleProtocolBuilder.moduleIdRemoveSlot:
        BleProtocolBuilder.msgIdType["request"]!,
    BleProtocolBuilder.moduleIdPlaySlot:
        BleProtocolBuilder.msgIdType["request"]!,
    BleProtocolBuilder.moduleIdUpdateFrameStart:
        BleProtocolBuilder.msgIdType["request"]!,
    BleProtocolBuilder.moduleIdUpdateFrameFinish:
        BleProtocolBuilder.msgIdType["request"]!,
    BleProtocolBuilder.moduleIdUpdateFrame:
        BleProtocolBuilder.msgIdType["request"]!,
    BleOriginalProtocolBuilder.moduleIdStreamFrameStart:
        BleProtocolBuilder.msgIdType["stream"]!,
    BleOriginalProtocolBuilder.moduleIdStreamFrameFinish:
        BleProtocolBuilder.msgIdType["request"]!,
  };

  @override
  Uint8List getProtocol(int typeValue,
      {int? index, Uint8List? data, int? frameSize = 1}) {
    /// 공용
    if (typeValue == BleProtocolBuilder.moduleIdSetDeviceState) {
      // 다른 타입도 변경할 수 있어 보이지만 실제 사용시에는 REQUEST로만 변경하기 때문에 형태 고정
      return Uint8List.fromList(
          [0xFA, 0x01, 0x00, 0x04, 0x01, 0x00, 0x04, 0x01, 0x04, 0x55, 0xA9]);
    } else if (typeValue == BleProtocolBuilder.moduleIdBatteryLevel) {
      //형식 정해져있음
      return Uint8List.fromList([250, 1, 0, 3, 1, 0, 3, 2, 85, 169]);
    } else if (typeValue == BleProtocolBuilder.moduleIdUpdateFrameStart) {
      return _buildProtocolData(typeValue, index: index, frameSize: frameSize);
    } else if (typeValue == BleProtocolBuilder.moduleIdUpdateFrameFinish) {
      //형식 정해져있음
      return Uint8List.fromList(
          [0xFA, 0x01, 0x00, 0x03, 0x01, 0x00, 0x0C, 0x0D, 0x55, 0xA9]);
    } else if (typeValue == BleProtocolBuilder.moduleIdUpdateFrame) {
      return _buildProtocolData(typeValue,
          data: data, index: index, frameSize: frameSize);
    } else if (typeValue == BleProtocolBuilder.moduleIdRemoveSlot) {
      return _buildProtocolData(typeValue, index: index);
    } else if (typeValue == BleProtocolBuilder.moduleIdPlaySlot) {
      return _buildProtocolData(typeValue, index: index);
    }

    /// 오리지널 전용
    else if (typeValue == BleOriginalProtocolBuilder.moduleIdStreamFrameStart) {
      return _buildProtocolData(typeValue);
    } else if (typeValue ==
        BleOriginalProtocolBuilder.moduleIdStreamFrameFinish) {
      return _buildProtocolData(typeValue);
    }

    return Uint8List.fromList([]);
  }

  @override
  Uint8List _buildProtocolData(int type,
      {int? index, Uint8List? data, int? frameSize}) {
    var value = <int>[];
    var header = <int>[0xFA];
    var footer = <int>[0x55, 0xA9];
    value.addAll(header);
    value.add(msgIds[type]!); //request 1 ,.2  ..3
    //payload start////////////////
    var payload =
        _buildPayload(type, index: index, data: data, frameSize: frameSize);
    value.addAll(checkPayloadLength(payload));
    value.addAll(payload);
    value.add(checkSum(payload));
    //payload end////////////////
    value.addAll(footer);
    return Uint8List.fromList(value);
  }

  @override
  List<int> _buildPayload(int type,
      {int? index, Uint8List? data, int? frameSize}) {
    var payload = <int>[];

    /// 공용
    if (type == BleProtocolBuilder.moduleIdBatteryLevel) {
      payload.add(0x01);
      payload.addAll(_buildModuleId(type));
    } else if (type == BleProtocolBuilder.moduleIdUpdateFrameStart) {
      payload.add(0x01); //module number
      payload
          .addAll(_buildModuleId(BleProtocolBuilder.moduleIdUpdateFrameStart));
      payload.add(index!); //index번 슬롯
      payload.addAll(buildFrameSize(frameSize ?? 1)); //total frame 숫자
    } else if (type == BleProtocolBuilder.moduleIdUpdateFrameFinish) {
      payload.add(0x01); //module number
      payload.addAll(_buildModuleId(
          BleProtocolBuilder.moduleIdUpdateFrameFinish)); //module id
    } else if (type == BleProtocolBuilder.moduleIdUpdateFrame) {
      /// 문서에 없는 내용인데 프레임 3장짜리라고 하면
      /// A. 1,2,3을 묶어서 [1(1번째 프레임), interval(속도) 30, 프레임 데이터 54byte, 2(2번째 프레임), 30, 프레임 데이터 54byte, 3(3번째 프레임), 30, 프레임 데이터 54byte]
      /// B. [1(1번째 프레임), interval(속도) 30, 프레임 데이터 54byte], [2(2번째 프레임), 30, 프레임 데이터 54byte], [3(3번째 프레임), 30, 프레임 데이터 54byte]
      /// A 처럼 묶어서 한번만 요청하거나, B 처럼 프레임을 분리해서 보내되 프레임 넘버링을 해주면 동작하지 않는다. 따라서
      /// C. [1(1번째 프레임), interval(속도) 30, 프레임 데이터 54byte], [1(2번째 프레임), 30, 프레임 데이터 54byte], [1(3번째 프레임), 30, 프레임 데이터 54byte]
      /// C 와 같이 처리해주어야 한다
      payload.add(0x01); //module number
      payload.addAll(
          _buildModuleId(BleProtocolBuilder.moduleIdUpdateFrame)); //module id
      payload.add(0x01); // 프레임은 1개씩 순서대로 보낸다
      payload.addAll(data!);
    } else if (type == BleProtocolBuilder.moduleIdRemoveSlot) {
      payload.add(0x01); //module number
      payload.addAll(_buildModuleId(BleProtocolBuilder.moduleIdRemoveSlot));
      payload.add(index ?? 0); //혹시라도 index가 없으면 기본값은 전체삭제
    } else if (type == BleProtocolBuilder.moduleIdPlaySlot) {
      payload.add(0x01); //module number
      payload.addAll(_buildModuleId(BleProtocolBuilder.moduleIdPlaySlot));
      payload.add(index ?? 0);
    }

    /// 오리지널 전용
    else if (type == moduleIdStreamFrameStart) {
      payload.add(0x01);
      payload.addAll(_buildModuleId(moduleIdStreamFrameStart));
      payload.addAll(data!.toList()); //LED DUMMY
    } else if (type == moduleIdStreamFrameFinish) {
      payload.add(0x01);
      payload.addAll(_buildModuleId(moduleIdStreamFrameFinish));
    }
    return payload;
  }

  List<int> buildFrameSize(int size) {
    List<int> lens = [];
    lens.add(size ~/ 256); //0x00 1번자리
    lens.add(size % 256); //0x00 2번자리
    return lens;
  }

  //페이로드값 검증 숫자 생성
  int checkSum(List<int> payload) {
    int checksum = 0;
    for (var element in payload) {
      checksum = (checksum ^ element);
    }
    return checksum;
  }

  @override
  List<int> _buildModuleId(int moduleId) {
    debugPrint('moduleId=0x${moduleId.toRadixString(16)}');
    List<int> lens = [];
    lens.add(moduleId ~/ 256); //0x00 1번자리
    lens.add(moduleId % 256); //0x00 2번자리
    return lens;
  }

  /// 오리지널 스트림 프로토콜
  @override
  Uint8List getRealtimeStartProtocol(FramesData framesData, {int index = 0}) {
    var value = <int>[];
    var header = <int>[0xFA];
    var footer = <int>[0x55, 0xA9];
    value.addAll(header);
    value.add(BleProtocolBuilder.msgIdType["stream"]!);
    debugPrint(
        "getRealtimeStreamProtocol length:${Uint8List.fromList(framesData.getFrameData(index)).length}");
    var payload = _buildPayload(moduleIdStreamFrameStart,
        data: Uint8List.fromList(framesData.getFrameData(index)));
    value.addAll(checkPayloadLength(payload));
    value.addAll(payload);
    value.add(checkSum(payload));
    //payload end////////////////
    value.addAll(footer);
    return Uint8List.fromList(value);
  }

  @override
  Uint8List getRealtimFinishProtocol() {
    Uint8List list = getProtocol(moduleIdStreamFrameFinish);
    return list;
  }
}

/// 컬러 전용 프로토콜 빌더
class BleColorProtocolBuilder extends BleProtocolBuilder {
  static int moduleIdStreamFrameFinish = 0x0004;
  static int moduleIdStreamFrameStart = 0x0005;
  static int moduleIdStreamFrame = 0x0006;

  // 메세지 아이디
  Map<int, int> msgIds = {
    ///  컬러에서는 해당 프로토콜이 없고, 0x0004가 moduleIdStreamFrameFinish 로 쓰인다
    /// BleProtocolBuilder.moduleIdSetDeviceState:BleProtocolBuilder.msgIdType["request"]!,
    BleProtocolBuilder.moduleIdBatteryLevel:
        BleProtocolBuilder.msgIdType["request"]!,
    BleProtocolBuilder.moduleIdRemoveSlot:
        BleProtocolBuilder.msgIdType["request"]!,
    BleProtocolBuilder.moduleIdPlaySlot:
        BleProtocolBuilder.msgIdType["request"]!,
    BleProtocolBuilder.moduleIdUpdateFrameStart:
        BleProtocolBuilder.msgIdType["request"]!,
    BleProtocolBuilder.moduleIdUpdateFrameFinish:
        BleProtocolBuilder.msgIdType["request"]!,
    BleProtocolBuilder.moduleIdUpdateFrame:
        BleProtocolBuilder.msgIdType["request"]!,

    BleColorProtocolBuilder.moduleIdStreamFrameStart:
        BleProtocolBuilder.msgIdType["stream"]!,
    BleColorProtocolBuilder.moduleIdStreamFrameFinish:
        BleProtocolBuilder.msgIdType["request"]!,
    BleColorProtocolBuilder.moduleIdStreamFrame:
        BleProtocolBuilder.msgIdType["stream"]!,
  };

  @override
  Uint8List getProtocol(int typeValue,
      {int? index, Uint8List? data, int? frameSize = 1}) {
    /// 공용
    if (typeValue == BleProtocolBuilder.moduleIdBatteryLevel) {
      //형식 정해져있음
      return Uint8List.fromList([250, 1, 0, 3, 1, 0, 3, 2, 85, 169]);
    } else if (typeValue == BleProtocolBuilder.moduleIdUpdateFrameStart) {
      return _buildProtocolData(typeValue, index: index, frameSize: frameSize);
    } else if (typeValue == BleProtocolBuilder.moduleIdUpdateFrameFinish) {
      //형식 정해져있음
      return Uint8List.fromList(
          [0xFA, 0x01, 0x00, 0x03, 0x01, 0x00, 0x0C, 0x0D, 0x55, 0xA9]);
    } else if (typeValue == BleProtocolBuilder.moduleIdUpdateFrame) {
      return _buildProtocolData(typeValue,
          data: data, index: index, frameSize: frameSize);
    } else if (typeValue == BleProtocolBuilder.moduleIdRemoveSlot) {
      return _buildProtocolData(typeValue, index: index);
    } else if (typeValue == BleProtocolBuilder.moduleIdPlaySlot) {
      return _buildProtocolData(typeValue, index: index);
    }

    /// 컬러 전용
    else if (typeValue == BleColorProtocolBuilder.moduleIdStreamFrameStart) {
      //todo 체크필요 구현은 했으나, BleColorProtocolBuilder.moduleIdStreamFrame 구현이 이상해서 묶음 구현 안됨
      return _buildProtocolData(typeValue, frameSize: frameSize);
    } else if (typeValue == BleColorProtocolBuilder.moduleIdStreamFrameFinish) {
      //todo 체크필요 구현은 했으나, BleColorProtocolBuilder.moduleIdStreamFrame 구현이 이상해서 묶음 구현 안됨
      return _buildProtocolData(typeValue, frameSize: frameSize);
    } else if (typeValue == BleColorProtocolBuilder.moduleIdStreamFrame) {
      //todo 체크필요 정확한 구현 안됨
      return _buildProtocolData(typeValue, data: data);
    }
    return Uint8List.fromList([]);
  }

  /// 컬러 스트림 프로토콜
  @override
  Uint8List getRealtimeStartProtocol(FramesData framesData, {int index = 0}) {
    var value = <int>[];
    var header = <int>[0xFA];
    var footer = <int>[0x55, 0xA9];
    value.addAll(header);
    value.add(BleProtocolBuilder.msgIdType["stream"]!);
    debugPrint(
        "getRealtimeStreamProtocol length:${Uint8List.fromList(framesData.getFramesToList().sublist(index)).length}");
    var payload = _buildPayload(moduleIdStreamFrameStart,
        frameSize: framesData.getFramesSize(),
        data: Uint8List.fromList(framesData.getFramesToList().sublist(index)));
    value.addAll(checkPayloadLength(payload));
    value.addAll(payload);
    value.add(checkSum(payload));
    //payload end////////////////
    value.addAll(footer);
    return Uint8List.fromList(value);
  }

  @override
  Uint8List _buildProtocolData(int type,
      {int? index, Uint8List? data, int? frameSize}) {
    var value = <int>[];
    var header = <int>[0xFA];
    var footer = <int>[0x55, 0xA9];
    value.addAll(header);
    value.add(msgIds[type]!); //request 1 ,.2  ..3
    //payload start////////////////
    var payload =
        _buildPayload(type, index: index, data: data, frameSize: frameSize);
    value.addAll(checkPayloadLength(payload));
    value.addAll(payload);
    value.add(checkSum(payload));
    //payload end////////////////
    value.addAll(footer);
    return Uint8List.fromList(value);
  }

  @override
  List<int> _buildPayload(int type,
      {int? index, Uint8List? data, int? frameSize}) {
    var payload = <int>[];

    /// 공용
    if (type == BleProtocolBuilder.moduleIdBatteryLevel) {
      payload.add(0x01);
      payload.addAll(_buildModuleId(type));
    } else if (type == BleProtocolBuilder.moduleIdUpdateFrameStart) {
      /// 오리지널과 동일
      payload.add(0x01); //module number
      payload
          .addAll(_buildModuleId(BleProtocolBuilder.moduleIdUpdateFrameStart));
      payload.add(index!); //index번 슬롯
      payload.addAll(buildFrameSize(frameSize ?? 1)); //total frame 숫자
    } else if (type == BleProtocolBuilder.moduleIdUpdateFrameFinish) {
      /// 오리지널과 동일
      payload.add(0x01); //module number
      payload.addAll(_buildModuleId(
          BleProtocolBuilder.moduleIdUpdateFrameFinish)); //module id
    } else if (type == BleProtocolBuilder.moduleIdUpdateFrame) {
      /// todo 아래 내용이 컬러와 오리지널이 다르게 구현되는 것으로 보임
      /// todo 컬러는 전체 frame size / 속도(interval) + 864 bytes / 속도(interval) + 864 bytes / .... 구조로 한번에 보내는 것으로 보임
      /// todo 따라서 컬러의 경우는 frameSize  / 프레임 전체를 가져오는 구조로 진행
      /// todo 그런데 어차피 이 프로토콜의 경우는 현재 1개의 프레임을 실시간으로 보여주는게 목적이라서
      /// todo 1프레임을 기준으로 동작확인하면 될 것으로 보임
      /// 오리지널의 경우 문서에 없는 내용인데 프레임 3장짜리라고 하면
      /// A. 1,2,3을 묶어서 [1(1번째 프레임), interval(속도) 30, 프레임 데이터 54byte, 2(2번째 프레임), 30, 프레임 데이터 54byte, 3(3번째 프레임), 30, 프레임 데이터 54byte]
      /// B. [1(1번째 프레임), interval(속도) 30, 프레임 데이터 54byte], [2(2번째 프레임), 30, 프레임 데이터 54byte], [3(3번째 프레임), 30, 프레임 데이터 54byte]
      /// A 처럼 묶어서 한번만 요청하거나, B 처럼 프레임을 분리해서 보내되 프레임 넘버링을 해주면 동작하지 않는다. 따라서
      /// C. [1(1번째 프레임), interval(속도) 30, 프레임 데이터 54byte], [1(2번째 프레임), 30, 프레임 데이터 54byte], [1(3번째 프레임), 30, 프레임 데이터 54byte]
      /// C 와 같이 처리해주어야 한다
      payload.add(0x01); //module number
      payload.addAll(
          _buildModuleId(BleProtocolBuilder.moduleIdUpdateFrame)); //module id
      payload.add(frameSize!); // number of frames
      payload.addAll(data!);
    } else if (type == BleProtocolBuilder.moduleIdRemoveSlot) {
      payload.add(0x01); //module number
      payload.addAll(_buildModuleId(BleProtocolBuilder.moduleIdRemoveSlot));
      payload.add(index ?? 0); //혹시라도 index가 없으면 기본값은 전체삭제
    } else if (type == BleProtocolBuilder.moduleIdPlaySlot) {
      payload.add(0x01); //module number
      payload.addAll(_buildModuleId(BleProtocolBuilder.moduleIdPlaySlot));
      payload.add(index ?? 0);
    }

    /// 컬러 전용 코드
    ///
    /// 컬러에서는 moduleIdSetDeviceState = 0x0004 가 삭제되었음
    /// 오리지널에서는 기기가 play중이거나 할 때, 상태를 request로 한번 바꿔주고 슬롯 삭제와
    /// 데이터 전송을 하는 구조가 있어서 컬러에서의 동작은 테스트가 필요해보임
    ///
    /// 오리지널에서는
    /// moduleIdStreamFrameStart 에 데이터를 담아서 보내고,
    /// moduleIdStreamFrameFinish 에서 종료를 전달하지만
    ///
    /// 컬러에서는
    /// moduleIdStreamFrameStart 으로 통신 시작을 알리고 (이 때 프레임이 몇장인지 미리 전송)
    /// moduleIdStreamFrame (0x0006)이 새로 추가되어 프레임 데이터를 담아서 전송후
    /// moduleIdStreamFrameFinish 에서 프레임 몇장인지를 담아서 최종 전송한다

    else if (type == moduleIdStreamFrameStart) {
      payload.add(0x01);
      payload.addAll(_buildModuleId(moduleIdStreamFrameStart));
      payload.add(frameSize!);
      // payload.addAll(data!.toList()); //LED DUMMY
    } else if (type == moduleIdStreamFrameFinish) {
      payload.add(0x01);
      payload.addAll(_buildModuleId(moduleIdStreamFrameFinish));
      payload.add(frameSize!);
    } else if (type == moduleIdStreamFrame) {
      payload.add(0x01); //module number
      payload.addAll(_buildModuleId(moduleIdStreamFrame));
      //todo 처리필요
      //
    }

    return payload;
  }

  //페이로드값 검증 숫자 생성
  int checkSum(List<int> payload) {
    print(payload);
    int checksum = 0;
    for (var element in payload) {
      checksum = (checksum ^ element);
    }
    return checksum;
  }

  @override
  List<int> _buildModuleId(int moduleId) {
    debugPrint('moduleId=0x${moduleId.toRadixString(16)}');
    List<int> lens = [];
    lens.add(moduleId ~/ 256); //0x00 1번자리
    lens.add(moduleId % 256); //0x00 2번자리
    return lens;
  }

  @override
  Uint8List getRealtimFinishProtocol() {
    Uint8List list = getProtocol(moduleIdStreamFrameFinish);
    return list;
  }

  //todo 맞는지 예시값과 확인 필요
  List<int> buildFrameSize(int size) {
    List<int> lens = [];
    lens.add(size ~/ 256); //0x00 1번자리
    lens.add(size % 256); //0x00 2번자리
    return lens;
  }
}
