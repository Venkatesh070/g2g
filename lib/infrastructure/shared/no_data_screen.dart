import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../res.dart';
import '../theme/colors.theme.dart';
import '../theme/text.theme.dart';

noDataScreen({noDataImage,title,subtitle,isShown}){
  return Column(
    children: [
    Visibility(
      visible: isShown==null?true:false,
      child:    Image.asset(
      noDataImage ?? Res.splashLogo,
      width: 120,
      height: 120,
    ),),
      Container(
        margin: const EdgeInsets.only(top: 10),
        child: Text(
          title ?? ''.tr,
          textAlign: TextAlign.center,
          style: semiBoldTextStyle(fontSize: dimen17, color: ColorsTheme.colBlack),
        ),
      ),
      Container(
        margin: const EdgeInsets.only(top: 10,left: 20,right: 20),
        alignment: Alignment.center,
        child: Text(
          subtitle ?? ''.tr,
          textAlign: TextAlign.center,
          style: regularTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
        ),
      ),
    ],
  );
}