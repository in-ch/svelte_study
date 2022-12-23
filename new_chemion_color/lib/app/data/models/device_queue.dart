// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:new_chemion_color/app/data/enums/enums.dart';
import 'package:new_chemion_color/app/data/models/models.dart';

class DeviceQueueLog {
  String deviceId;
  DateTime dateTime;
  bool isWrite;
  List<int> list;
  dynamic error;
  DeviceQueueLog(
      {required this.deviceId,
      required this.dateTime,
      required this.isWrite,
      required this.list,
      error});
}

class DeviceQueue {
  DeviceQueue(this.device);

  BleDeviceItem device;

  List<DeviceQueueLog> logs = []; // 디바이스 큐 로그

  var logger = Logger();

  DateTime currentTime = DateTime.now();

  final BuildContext? context =
      ChemionGlobalVariable.naviagatorState.currentContext;

  /// 장치 요청/응답 로그 목록
  /////////////////////////////////////////////////////////////////////////////
  static const int MAX_REQUEST_RETRY_COUNT = 1; //최대 재요청 횟수

  /// Queue 처리를 할 장치
  bool isRequesting = false; //요청 진행중
  DeviceQueueRequest? selectedQueue;
  int currentTryCount = 0;
  Queue<DeviceQueueRequest> queue = Queue<DeviceQueueRequest>();
  StreamSubscription<CharacteristicWithValue>? monitor;

  /// deviceDisconnect 시에 진행중인 Queue가 있으면 쌓인 Queue는 전부 취소하고
  /// 현재 진행중인 Queue 내용이 끝나도록 대기 후에 연결 해제
  /// 진행중이던 마지막 남은 응답이 시간이 10초 이상 걸리면 그냥 강제 종료 및 연결 해제
  Future<void> disconnect({int retryCount = 0}) async {
    logger.e("장비 연결이 끊어졌습니다. 사용자에게도 알려주세요.");
    // context!.read<StaticProvider>().showDisconnected();
    if (queue.isEmpty) {
      device.peripheral.disconnectOrCancelConnection();
    } else {
      if (retryCount > 10) {
        // 10초 넘기면 강제종료
        Fluttertoast.cancel();
        Fluttertoast.showToast(
            msg: "toast_disconnect".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        device.peripheral.disconnectOrCancelConnection();
        // context!.read<StaticProvider>().showDisconnected();
      } else {
        // Queue 쌓인 요청 처리 기다리고 다시 disconnect 요청
        Future.delayed(const Duration(milliseconds: 500), () {
          disconnect(retryCount: retryCount + 1);
        });
      }
    }
  }

  /// Queue에 처리할 Request 추가
  addRequests(List<DeviceQueueRequest> requests) {
    /// 기기별 요청 큐에 추가

    logger.wtf("Request Queue Start");

    for (var request in requests) {
      queue.addFirst(request);
    }

    /// 이미 전송 중이면 추가적인 요청 취소, 전송중이 아니면 요청 전송
    if (isRequesting) return;

    /// 스트림이 오류가 나면 cancel 될 수 있어서 한번 요청시마다 기존 스트림 취소 후 새로 생성
    monitor?.cancel();
    monitor = monitorCharacteristic(device.peripheral, device, onData, onError);
    sendRequests();
  }

  /// 순차적으로 request를 시작한다 (재귀함수구조)
  /// 전송 시, mtu 220을 넘는 요청은 분할해서 전송
  /// 2회 요청시에도 실패하는 경우에는 큐의 남은 전체 요청을 취소한다
  Future<void> sendRequests({bool isRetry = false}) async {
    logger.wtf("sendRequests");
    isRequesting = true; // 전체요청시작

    if (!isRetry && queue.isNotEmpty) {
      /// 신규시도, 초기값 설정 및 마지막 큐를 가져온다
      selectedQueue = queue.last;
      queue.removeLast();
      currentTryCount = 0;
    } else if (!isRetry && queue.isEmpty) {
      /// 신규시도인데, 큐에 남은 요청이 없으면 종료
      isRequesting = false;
      return;
    }

    ///재시도는 별도로 초기값 입력 X

    /// MTU (한번에 보낼 수 있는 데이터길이) 에 맞춰서 request 데이터를 잘라서 기기에 전송
    int mtu = DeviceInfo.getMTU(device.getDeviceTypeFromUUID());
    var listsize = selectedQueue!.value.length ~/ mtu;

    /// MTU 1사이즈보다 작으면 1회로 바로 요청, 1사이즈(220)보다 크면 mtu 로 분할해서 요청
    if (selectedQueue!.value.length <= mtu) {
      writeCharacteristic(device, selectedQueue!.value, true);
    } else {
      await Future.forEach(List<int>.generate(listsize, (index) => index + 1),
          (int index) async {
        int i = index - 1;
        var sublist = selectedQueue!.value.sublist(i * mtu, (i + 1) * mtu);
        var value = Uint8List.fromList(sublist);

        /// 이부분 MTU로 컷팅 후 요청종료 Footer 없는 부분은
        /// writeCharacteristic(device, value, false) 로 처리
        writeCharacteristic(device, value, false);
      });

      if (selectedQueue!.value.length % mtu != 0) {
        var sublist = selectedQueue!.value.sublist((listsize) * mtu);
        var value = Uint8List.fromList(sublist);

        /// 여기서 await writeC... 을 추가해야하는지 아닌지 고민 필요. 실제 기기 전송시에 문제가
        /// 없을지 고민... 일단은 마지막 빌드에서 문제가 없던것으로 보여서 없이 처리
        writeCharacteristic(device, value, true);
      }
    }
    return;
  }

  /// 데이터 수신부
  /// 요청이 시작되었을 때 잘못된 응답이 오면 1회 더 요청 후 재실패시 전체 큐 종료
  onData(event) {
    isRequesting = false;
    var value = event.value.toList();
    logs.add(DeviceQueueLog(
        deviceId: device.peripheral.identifier,
        dateTime: DateTime.now(),
        isWrite: false,
        list: value));
    var queueLength = queue.length;
    if (value != [15, 10, 169]) {
      openDialog(queueLength);
    }
    if (checkValidResponse(value)) {
      sendRequests();
    }
  }

  /// 데이터 수신 오류부
  /// 1회차까지는 재시도, 2회차에서는 전체 대기큐 삭제하고 종료
  onError(error, st) {
    logger.e("데이터 수신부 오류 발생 : $error");
    isRequesting = false;
    logs.add(DeviceQueueLog(
        deviceId: device.peripheral.identifier,
        dateTime: DateTime.now(),
        isWrite: false,
        list: [],
        error: error));
    actionInvalidResponse();
  }

  /// write 부분 함수처리
  Future<void> writeCharacteristic(
      BleDeviceItem device, Uint8List value, bool withResponse) async {
    logs.add(DeviceQueueLog(
        deviceId: device.peripheral.identifier,
        dateTime: DateTime.now(),
        isWrite: true,
        list: value));
    device.peripheral.writeCharacteristic(
        DeviceInfo().getServiceUuid(device.getDeviceTypeFromUUID()),
        DeviceInfo().getWriteUuid(device.getDeviceTypeFromUUID()),
        value,
        withResponse);
  }

  /// monitor 부분 함수처리
  StreamSubscription<CharacteristicWithValue> monitorCharacteristic(
      Peripheral peripheral,
      BleDeviceItem device,
      void Function(CharacteristicWithValue) onData,
      Function? onError) {
    return peripheral
        .monitorCharacteristic(
            DeviceInfo().getServiceUuid(device.getDeviceTypeFromUUID()),
            DeviceInfo().getNotiUuid(device.getDeviceTypeFromUUID()))
        .listen(onData, onError: onError, cancelOnError: true);
  }

  /// Reply or Notify 일 때만 true (todo)Reply만 응답하면 될 것으로 보이는데, 일단은 Notify 응답도 정상으로 처리
  /// todo Delete Slot의 경우 기존에 슬롯이 비워져 있을 때에도 삭제를 요청하면 5 에러응답이 오는 것 같은데
  /// todo 이와 같이 프로토콜 별, 5가 뜨더라도 Queue를 유지할지, 초기화할지 분기를 태우는 기능이 필요 할것으로 보임
  bool checkValidResponse(List<int> value) {
    if (value[1] == 2 || value[1] == 4) {
      if (selectedQueue!.value[5] == value[5] &&
          selectedQueue!.value[6] == value[6]) {
        return true;
      }
    }
    return false;
  }

  /// 옳지않은 응답에 대한 동작 1회는 같은 내용 재요청, 2회차에는 오류 감지 후 전체 큐 종료
  void actionInvalidResponse() {
    if (currentTryCount < MAX_REQUEST_RETRY_COUNT) {
      currentTryCount += 1;
      sendRequests(isRetry: true);
    } else {
      /// 재시도 횟수 넘어가면 이후에 저장된 큐 전체 취소
      queue.clear();
    }
  }

  late BuildContext dialogContext;
  void openDialog(int num) {
    // final BuildContext? context =
    //     ChemionGlobalVariable.naviagatorState.currentContext;
    // context!.read<StaticProvider>().showLoading((100 / 4) * (4 - num));
    if (num == 0) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        // context.read<StaticProvider>().closeLoading();
      });
    }
  }
}
