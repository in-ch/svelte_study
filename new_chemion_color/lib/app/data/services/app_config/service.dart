import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart';
import 'package:android_intent/android_intent.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:new_chemion_color/app/data/enums/enums.dart';
import 'package:new_chemion_color/app/data/provider/api.dart';
import 'package:new_chemion_color/app/data/models/models.dart';
import 'package:new_chemion_color/app/data/services/app_config/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfigService extends GetxService {
  late AppConfigRepository repository;
  late GetStorage box;

  List<BleDeviceItem> connectedList = []; //연결 중인 장치
  List<BleDeviceItem> deviceList = []; // BLE 장치 리스트 변수
  List<BleDeviceItem> usedDeviceList = []; // 이전에 연결한 기록이 있는 장치
  List<BleDeviceItem> newDeviceList = []; // 이전에 연결한 기록이 없는 장치

  Map<String, DeviceQueue?> queueRequest =
      {}; // connectedDevice 추가되면 추가, disconnect되면 여기서 삭제.

  bool isScanning = false; // 블루투스 스캔 여부
  BleManager? bleManager = BleManager();
  BluetoothState? bleStatus = BluetoothState.UNKNOWN; //블루투스 연결 상태
  StreamSubscription<ScanResult>? scanning;

  Future<AppConfigService> init() async {
    repository = AppConfigRepository(MyApi());
    box = GetStorage();
    return this;
  }

  /// 블루투스가 꺼져있는지 체크한다.
  ///  2022-12-22 Seong incheol
  void requestBleTurnOn() {
    if (Platform.isAndroid) {
      AndroidIntent intent = const AndroidIntent(
          action: 'android.bluetooth.adapter.action.REQUEST_ENABLE');
      intent.launch();
    }
  }

  /// 블루투스 client를 생성한다.
  /// 2022-12-22 Seong incheol
  Future<void> createBleClient() async {
    bool isClientCreated = await bleManager?.isClientCreated() ?? false;
    if (isClientCreated) return;
    await bleManager?.createClient(
        restoreStateIdentifier: "restore",
        restoreStateAction: (peripherals) {});
    await bleManager?.setLogLevel(LogLevel.verbose); //ble 로그 레벨 설정
    bleStatus = await bleManager?.bluetoothState();
    bleManager?.observeBluetoothState().listen((status) async {
      if (status == BluetoothState.POWERED_OFF) {
        requestBleTurnOn();
      } else if (status == BluetoothState.POWERED_ON) {
        await startBleScan();
      }
      bleStatus = status;
    });
  }

  /// 블루투스 장비를 초기화 한다.
  /// 2022-12-22 Seong incheol
  void _deviceListClear() {
    deviceList.clear();
    usedDeviceList.clear();
    newDeviceList.clear();
  }

  /// 블루투스 스캔을 멈춘다.
  /// 2022-12-20 Seong incheol
  Future<void> stopBleScan() async {
    if (isScanning) await bleManager?.stopPeripheralScan();
    isScanning = false;
  }

  /// 블루투스 스캔을 시작한다.
  /// 2022-12-22 Seong incheol
  Future<void> startBleScan() async {
    _deviceListClear();
    isScanning = true;
    for (var connectedDevice in connectedList) {
      await rebuildDeviceListUI(connectedDevice);
    }
    scanning = bleManager
        ?.startPeripheralScan(uuids: DeviceInfo.chemionDeviceServiceUUIDs)
        .listen((scanResult) async {
      var name = scanResult.peripheral.name ?? "알 수 없는 기기";
      var findDevice = deviceList.any((existDevice) {
        if (existDevice.peripheral.identifier ==
            scanResult.peripheral.identifier) {
          existDevice.peripheral = scanResult.peripheral;
          existDevice.serviceUuid =
              scanResult.advertisementData.serviceUuids![0];
          existDevice.rssi = scanResult.rssi;
          return true;
        }
        return false;
      });
      if (!findDevice) {
        if (scanResult.advertisementData.serviceUuids == null ||
            scanResult.advertisementData.serviceUuids!.isEmpty) {
        } else {
          deviceList.add(BleDeviceItem(
              name,
              scanResult.rssi,
              scanResult.peripheral,
              scanResult.advertisementData.serviceUuids![0]));
          SharedPreferences prefs = await SharedPreferences.getInstance();
          List<String> usedDeviceListStr =
              prefs.getStringList("usedDevice") ?? [];

          BleDeviceItem searchedDevice = BleDeviceItem(
              name,
              scanResult.rssi,
              scanResult.peripheral,
              scanResult.advertisementData.serviceUuids![0]);

          List<int> body = const Utf8Encoder()
              .convert(scanResult.peripheral.name ?? "")
              .toList();
          searchedDevice.setPrivateDevice(body);
          if (usedDeviceListStr.contains(scanResult.peripheral.identifier)) {
            bool needBuild = true;
            for (var element in usedDeviceList) {
              if (element.peripheral.identifier ==
                  scanResult.peripheral.identifier) {
                needBuild = false;
              }
            }
            if (needBuild) usedDeviceList.add(searchedDevice);
          } else {
            if (!searchedDevice.isPrivateDevice) {
              newDeviceList.add(searchedDevice);
            }
            newDeviceList.add(searchedDevice);
          }
        }
      }
      if (Platform.isIOS) {
        bleManager?.stopPeripheralScan();
      }
    });
  }

  /// 연결만 되고 노출되지 않는 기기를 체크하여 처음부터 선택 상태인 DeviceList 추가
  /// 2022-12-22 Seong incheol
  Future<void> rebuildDeviceListUI(BleDeviceItem device) async {
    var aleadyExist = false;
    for (var connectedDevice in connectedList) {
      if (connectedDevice.deviceName == device.deviceName) {
        aleadyExist = true;
        bool isShowing = true;
        for (var usedDevice in usedDeviceList) {
          if (usedDevice.peripheral.identifier ==
              device.peripheral.identifier) {
            isShowing = false;
          }
        }
        if (isShowing) {
          usedDeviceList.add(device);
        }
      }
    }
    device.state = PeripheralConnectionState.connected;
    if (!aleadyExist) {
      await connectDevice(device);
      registerUsedDevice(device);
    }
  }

  /// 블루투스 장비 연결
  /// 2022-12-20 Seong incheol
  Future<void> connectDevice(BleDeviceItem selectedDevice) async {
    queueRequest[selectedDevice.peripheral.identifier] =
        DeviceQueue(selectedDevice);
    connectedList.add(selectedDevice);
  }

  /// 연결되었던 기기목록에 추가
  /// 2022-12-20 Seong incheol
  Future<void> registerUsedDevice(BleDeviceItem selectedDevice) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> usedDeviceListStr = prefs.getStringList("usedDevice") ?? [];
    if (!usedDeviceListStr.contains(selectedDevice.peripheral.identifier)) {
      usedDeviceListStr.add(selectedDevice.peripheral.identifier);
      usedDeviceListStr = usedDeviceListStr.toSet().toList();
      await prefs.setStringList("usedDevice", usedDeviceListStr);
    }
  }
}
