import 'package:flutter/material.dart';
import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'gradient_mask.dart';

import 'package:new_chemion_color/app/data/enums/enums.dart';
import 'package:new_chemion_color/app/data/models/models.dart';
import 'package:new_chemion_color/core/theme/app_colors.dart';

class DeviceListItem extends StatefulWidget {
  final BleDeviceItem device;
  // final Future<void> connect;

  const DeviceListItem(this.device, {Key? key}) : super(key: key);

  @override
  DeviceListItemState createState() => DeviceListItemState();
}

class DeviceListItemState extends State<DeviceListItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
// 0미선택, 1 로딩 2 연결 됨
//     print("listitem build "+state.toString());
    return InkWell(
      onTap: () async {
        // var selectedDeviceType =
        //     DeviceInfo.getTypeByDeviceUUID(widget.device.serviceUuid);
        // // context.read<MainProvider>().deviceMode = selectedDeviceType;
        // widget.connect(context, widget.device);
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Container(
          height: 78,
          decoration: _getItemDecoration(widget.device.state),
          child: Stack(
            children: [
              Positioned(
                left: 16,
                top: 17,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Image.asset(
                    _getDeviceTypeImagePath(
                        widget.device.getDeviceTypeFromUUID()),
                  ),
                ),
              ),
              Positioned(
                left: 84,
                top: 16,
                right: 64,
                child: SizedBox(
                  height: 20,
                  child:
                      widget.device.state == PeripheralConnectionState.connected
                          ? GradientText(widget.device.getDeviceTypeStr(),
                              colors: AppColors.fontGradients[1].colors)
                          : Text(
                              widget.device.getDeviceTypeStr(),
                              style: TextStyle(color: AppColors.colorFontGray),
                            ),
                ),
              ),
              Positioned(
                left: 84,
                bottom: 18,
                right: 64,
                child: SizedBox(
                  height: 16,
                  child:
                      widget.device.state == PeripheralConnectionState.connected
                          ? GradientText(widget.device.deviceName,
                              colors: AppColors.fontGradients[1].colors)
                          : Text(
                              widget.device.deviceName,
                              style: TextStyle(color: AppColors.colorFontGray),
                            ),
                ),
              ),
              (widget.device.state == PeripheralConnectionState.connecting ||
                      widget.device.state ==
                          PeripheralConnectionState.disconnecting)
                  ? Positioned(
                      top: 27,
                      right: 20,
                      bottom: 27,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: GradientImg("assets/images/ic_loading.png"),
                      ),
                    )
                  : Container(),
              (widget.device.state == PeripheralConnectionState.connected)
                  ? Positioned(
                      top: 27,
                      right: 20,
                      bottom: 27,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: GradientImg("assets/images/ic_check.png",
                            color: AppColors.colorSuccess),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
      // child: ,
    );
  }

  _getItemDecoration(PeripheralConnectionState state) {
    if (state != PeripheralConnectionState.connected) {
      return BoxDecoration(
        color: AppColors.colorLightBackground,
        border: Border.all(width: 1, color: AppColors.colorLightBackground),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      );
    } else {
      return BoxDecoration(
        color: AppColors.colorLightBackground,
        border: Border.all(width: 1, color: AppColors.colorSecondaryButtonEnd),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      );
    }
  }

  String _getDeviceTypeImagePath(DEVICE_TYPE type) {
    if (type == DEVICE_TYPE.TYPE_ORIGINAL) {
      return "assets/images/img_goggle_default.png";
    } else if (type == DEVICE_TYPE.TYPE_COLOR) {
      return "assets/images/img_goggle_color_default.png";
    } else if (type == DEVICE_TYPE.TYPE_HAT) {
      return "assets/images/img_hat_default.png";
    } else {
      return "assets/images/ic_loading.png";
    }
  }
}
