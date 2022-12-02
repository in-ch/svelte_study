import 'package:flutter/material.dart';

Widget splash() {
  return MaterialApp(
    home: Scaffold(
      body: Container(
        color: Colors.black,
        width: double.maxFinite,
        height: double.maxFinite,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset("assets/images/img_bg_splash.png"),
            ),
            Positioned(
              bottom: 0,
              top: 0,
              left: 0,
              right: 0,
              child: FractionallySizedBox(
                  widthFactor: 1,
                  heightFactor: 0.8,
                  child: Container(
                    margin: const EdgeInsets.only(left: 80, right: 80),
                    child: Image.asset("assets/images/img_logo_splash.png"),
                  )),
            )
          ],
        ),
      ),
    ),
  );
}
