import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:new_chemion_color/app/modules/preview/controller.dart';
import 'package:new_chemion_color/app/modules/preview/widgets/widgets.dart';
import 'package:new_chemion_color/app/widgets/widgets.dart';
import 'package:new_chemion_color/app/data/models/models.dart';
import 'package:new_chemion_color/core/theme/app_colors.dart';
import 'package:new_chemion_color/routes/pages.dart';

class PreviewScreen extends GetView<PreviewController> {
  const PreviewScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        backgroundColor: AppColors.colorBackground,
        body: const SafeArea(child: ConnectableDevicesScreen()));
  }
}

class ConnectableDevicesScreen extends StatefulWidget {
  const ConnectableDevicesScreen({Key? key}) : super(key: key);

  @override
  State<ConnectableDevicesScreen> createState() =>
      _ConnectableDevicesScreenState();
}

class _ConnectableDevicesScreenState extends State<ConnectableDevicesScreen> {
  @override
  Widget build(BuildContext context) {
    List<BleDeviceItem> newDevices = [];
    List<BleDeviceItem> usedDevices = [];
    List<BleDeviceItem> connectedList = [];
    List<BleDeviceItem> totalDevice = newDevices + usedDevices + connectedList;

    return Column(
      children: [
        // Actionbar(startBleScan: startBleScan, connectedList: connectedList)
        Container(
          margin: const EdgeInsets.only(top: 20),
          height: 30,
          child: Image.asset("assets/images/img_logo_chemion.png"),
        ),
        Container(
          margin: const EdgeInsets.only(top: 20, bottom: 14),
          height: 30,
          child: Text(
            "choice_devices".tr(),
            style: TextStyle(color: AppColors.colorFontLightGray),
          ),
        ),
        Expanded(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (usedDevices.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 32),
                      height: 40,
                      width: double.maxFinite,
                      child: Text(
                        "registered_device".tr(),
                        style: TextStyle(color: AppColors.colorFontLightGray),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  if (usedDevices.isNotEmpty)
                    registeredDevicesListWidget(
                        context, totalDevice, newDevices, usedDevices),
                  if (newDevices.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 32),
                      height: 40,
                      width: double.maxFinite,
                      child: Text(
                        "connectable_device".tr(),
                        style: TextStyle(color: AppColors.colorFontLightGray),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  if (newDevices.isNotEmpty)
                    searchedDevicesListWidget(
                        context, totalDevice, newDevices, usedDevices),
                  connectedList.isNotEmpty
                      ? Container(
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 24),
                          height: 56,
                          width: double.maxFinite,
                          child: InkWell(
                              onTap: () async {
                                await Navigator.pushNamed(context, Routes.home);
                                // await context
                                //     .read<MainProvider>()
                                //     .stopRealtimeFrameToDevices();
                              },
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(16)),
                                child: gradientWidget(Container(
                                  height: 56,
                                  alignment: Alignment.center,
                                  width: double.maxFinite,
                                  color: AppColors.colorSecondaryButtonEnd,
                                  child: Text(
                                    "button_start".tr(),
                                  ),
                                )),
                              )))
                      : Container(
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 24),
                          height: 56,
                          width: double.maxFinite,
                          child: InkWell(
                            onTap: () {},
                            child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(16)),
                                child: Container(
                                  height: 56,
                                  alignment: Alignment.center,
                                  width: double.maxFinite,
                                  color: AppColors.colorDisabled,
                                  child: Text(
                                    "button_start".tr(),
                                  ),
                                )),
                          )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
