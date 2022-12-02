import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  Color colorDEBUG = const Color(0x88666666);

  static Gradient primaryGradient = LinearGradient(
    colors: [colorPrimaryButtonEnd, colorPrimaryButtonStart],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );
  static Gradient buttonGradient = LinearGradient(
    colors: [colorPrimaryButtonEnd, colorPrimaryButtonStart],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static Gradient dropdownGradient = LinearGradient(
    colors: [colorDropdownEnd, colorDropdownStart],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
  static Color colorPrimaryButtonStart = const Color(0xff9254FF);
  static Color colorPrimaryButtonEnd = const Color(0xff583FFF);

  static Gradient secondaryGradient = LinearGradient(
    // 1:4 비
    colors: [
      colorSecondaryButtonEnd,
      colorSecondaryButtonStart,
      colorSecondaryButtonStart,
      colorSecondaryButtonStart
    ],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );
  static Color colorSecondaryButtonStart = const Color(0xffA876FF);
  static Color colorSecondaryButtonEnd = const Color(0xff8573FF);

  static Color colorSuccess = const Color(0xff37e4bb);
  static Color colorError = const Color(0xffff7878);

  static Color colorTitleIcon = const Color(0xffffffff);
  static Color colorLightGray = const Color(0xffD0D0D0);
  static Color colorLightGray2 = const Color(0xffA0A0A1);
  static Color colorGray = const Color(0xff59595B);
  static Color colorDarkGray = const Color(0xff363638);

  static Color colorDisabled = const Color(0xff141414);
  static Color colorDisabledText = const Color(0xff2a2a2a);
  static Color colorDisabledTabText = const Color(0xff505050);

  static Color colorBackground = const Color(0xff050505);
  static Color colorLightBackground = const Color(0xff191A1F);
  static Color colorNavigatorLightBackground = const Color(0xff191A1F);

  static Color colorBrightBlack = const Color(0xff363638);
  static Color colorBrightDarkGray = const Color(0xff59595B);
  static Color colorBrightkGray = const Color(0xffA0A0A1);
  static Color colorBrightkLightGray5 = const Color(0xffD0D0D0);
  static Color colorBrightkLightGray6 = const Color(0xffECEDEE);

  static Color colorInput = const Color(0xff222222a);

  static Color colorFontGray = const Color(0xff9b9b9b);
  static Color colorFontLightGray = const Color(0xffcdcede);
  static Color colorFontLightGray2 = const Color(0xffcdcdcd);
  List<Color> fontColors = [
    colorTitleIcon, // 0
    colorLightGray, // 1
    colorFontGray, // 2
    colorFontLightGray, // 3
    colorDisabledText, // 4
    colorLightGray2, // 5
    colorFontLightGray2, // 6
    colorToastRed, // 7
    colorDisabledTabText, // 8
    colorSecondaryButtonStart, // 9
    colorSecondaryButtonEnd // 10
  ];
  static List<Gradient> fontGradients = [primaryGradient, secondaryGradient];

  static Color colorBuilderCard01 = const Color(0xff4D53E9);
  static Color colorBuilderCard02 = const Color(0xff715DED);
  static Color colorBuilderCard03 = const Color(0xff9062F0);

  static Color colorToastGreen = const Color(0xff02c798);
  static Color colorToastRed = const Color(0xffff7878);
  static List<Color> cardColors = [
    colorBuilderCard01,
    colorBuilderCard02,
    colorBuilderCard03
  ];
  static List<Color> toastColors = [
    colorSecondaryButtonStart,
    colorToastGreen,
    colorToastRed
  ];

  static Color colorDropdownStart = const Color(0xffe8dbff);
  static Color colorDropdownEnd = const Color(0xffe0dbff);
//todo 임시
  Gradient gradientDeviceItem(int status) {
    if (status == 0) {
      return LinearGradient(
        colors: [colorLightBackground, colorLightBackground],
        begin: const Alignment(-1, -1),
        end: const Alignment(2, 2),
      );
    } else {
      return LinearGradient(
        colors: [colorSecondaryButtonEnd, colorSecondaryButtonStart],
        begin: const Alignment(-1, -1),
        end: const Alignment(2, 2),
      );
    }
  }
}
