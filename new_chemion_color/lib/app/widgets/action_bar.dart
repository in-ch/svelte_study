// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:new_chemion_color/core/theme/app_colors.dart';
import 'package:new_chemion_color/routes/pages.dart';
import 'package:new_chemion_color/app/data/models/models.dart';

class Actionbar extends StatelessWidget {
  Actionbar({
    Key? key,
    required this.startBleScan,
    required this.connectedList,
  }) : super(
          key: key,
        );
  Future<void> startBleScan;
  List<BleDeviceItem> connectedList;

  Future<bool> checkConnectivity() async {
    late ConnectivityResult result;
    try {
      final Connectivity connectivity = Connectivity();
      result = await connectivity.checkConnectivity();
      return result == ConnectivityResult.none ? false : true;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.maxFinite,
      child: Stack(
        children: [
          Positioned(
            left: 4,
            top: 0,
            bottom: 0,
            child: InkWell(
              onTap: () async {
                try {
                  startBleScan;
                } catch (e) {
                  debugPrint(e.toString());
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Image.asset("assets/images/ic_sync.png"),
              ),
            ),
          ),
          connectedList.isEmpty
              ? Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: InkWell(
                    child: Container(
                      height: 32,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(left: 12, right: 12),
                      child: OutlinedButton(
                        onPressed: () async {
                          bool connected = await checkConnectivity();
                          if (connected) {
                            await Navigator.pushNamed(context, Routes.home);
                          } else {
                            Fluttertoast.showToast(
                                msg: "인터넷 연결을 확인해주세요.",
                                backgroundColor: const Color(0xff9254FF),
                                textColor: Colors.white,
                                fontSize: 15.0,
                                toastLength: Toast.LENGTH_SHORT,
                                timeInSecForIosWeb: 4,
                                gravity: ToastGravity.BOTTOM);
                            throw Exception();
                          }
                        },
                        child: GradientText(
                          "start_with_no_device".tr(),
                          colors: AppColors.fontGradients[1].colors,
                        ),
                      ),
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
