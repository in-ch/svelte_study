import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import 'package:new_chemion_color/app/modules/preview/controller.dart';
import 'package:new_chemion_color/core/theme/app_colors.dart';

class PreviewScreen extends GetView<PreviewController> {
  const PreviewScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        backgroundColor: AppColors.colorBackground,
        body: SafeArea(
            child: Column(
          children: const [
            Expanded(
                child: Text(
              "Hello",
              style: TextStyle(color: Colors.white),
            )),
          ],
        )));
  }
}
