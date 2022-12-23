// ignore_for_file: non_constant_identifier_names, sort_child_properties_last

import 'package:flutter/widgets.dart';

import 'package:new_chemion_color/core/theme/app_colors.dart';

/// 그래디언트 이미지 위젯
ShaderMask GradientImg(String imgPath, {Color? color}) {
  var colorList = [
    AppColors.colorPrimaryButtonEnd,
    AppColors.colorPrimaryButtonStart
  ];
  if (color != null) {
    colorList.clear();
    colorList = [color, color];
  }
  return ShaderMask(
    child: Image(
      image: AssetImage(imgPath),
    ),
    shaderCallback: (Rect bounds) {
      return LinearGradient(
        colors: colorList,
        stops: const [
          0.0,
          0.5,
        ],
      ).createShader(bounds);
    },
    blendMode: BlendMode.srcATop,
  );
}

ShaderMask gradientWidget(Widget widget) {
  return ShaderMask(
    child: widget,
    shaderCallback: (Rect bounds) {
      return LinearGradient(
        colors: [
          AppColors.colorPrimaryButtonStart,
          AppColors.colorPrimaryButtonEnd
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [
          0.0,
          0.5,
        ],
      ).createShader(bounds);
    },
    blendMode: BlendMode.hue,
  );
}
