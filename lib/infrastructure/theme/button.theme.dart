import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/theme/text.theme.dart';
import 'colors.theme.dart';

ElevatedButtonThemeData buttonTheme = ElevatedButtonThemeData(
    style: ButtonStyle(
        shape: MaterialStateProperty.resolveWith<OutlinedBorder>((_) {
          return RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
        }),
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) => ColorsTheme.colBackground)));

customButton({required String text, required margin, padding, textStyle, buttonColor}) {
  return Container(
    decoration: BoxDecoration(color: buttonColor ?? Get.theme.primaryColor, borderRadius: BorderRadius.circular(50)),
    alignment: Alignment.center,
    margin: margin,
    width: Get.size.width / 1.7,
    padding: padding ?? EdgeInsets.zero,
    child: Text(
      text,
      style: textStyle ?? mediumTextStyle(fontSize: dimen16, color: ColorsTheme.colWhite),
    ),
  );
}
