import 'package:flutter/material.dart';

import 'colors.theme.dart';
import 'text.theme.dart';

AppBarTheme appBarTheme = const AppBarTheme();


appBarIconTitle({required Function onTapFunction,String? title,titleStyle, required margin}){
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      InkWell(
        onTap: () {
          onTapFunction();
        },
        child: Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back,
              size: 25,
              color: ColorsTheme.colBlack,
            )),
      ),
      title==null?Container():Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          title,
          style: titleStyle??appBarTextStyle(color: ColorsTheme.colBlack),
        ),
      )
    ],
  );
}

appBarCenterIconTitle({required Function onTapFunction,String? title,titleStyle, required margin}){
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      GestureDetector(
        onTap: () {
          onTapFunction();
        },
        child: Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back,
              size: 25,
              color: ColorsTheme.colBlack,
            )),
      ),
      title==null?Container():Expanded(
        child: Container(
          alignment: Alignment.center,
          child: Text(
            title,
            style: titleStyle??appBarTextStyle(color: ColorsTheme.colBlack),
          ),
        ),
      ),
      title==null?Container():const SizedBox(width: 30,)
    ],
  );
}

