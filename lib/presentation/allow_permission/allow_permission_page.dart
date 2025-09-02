import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/presentation/allow_permission/allow_permission_controller.dart';

import '../../infrastructure/theme/colors.theme.dart';
import '../../infrastructure/theme/text.theme.dart';
import '../../res.dart';

class AllowPermissionPage extends BaseView<AllowPermissionController>{
  AllowPermissionPage({super.key});


  @override
  Widget body(BuildContext context) {
    return SafeArea(child: Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    child: Text(
                      'Allow these permissions'.tr,
                      style: boldTextStyle(fontSize: dimen21, color: ColorsTheme.colBlack),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: Image.asset(
                      Res.icLocation,
                      width: 40,
                      height: 40,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Location'.tr,
                      style: semiBoldTextStyle(fontSize: dimen17, color: ColorsTheme.colBlack),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(
                      'location_permission_subtitle'.tr,
                      style: regularTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: Image.asset(
                      Res.icNotification,
                      width: 40,
                      height: 40,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Notification'.tr,
                      style: semiBoldTextStyle(fontSize: dimen17, color: ColorsTheme.colBlack),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(
                      'notification_permission_subtitle'.tr,
                      style: regularTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  controller.checkAndAllowPermission();
                },
                child: Container(
                  decoration: BoxDecoration(color: ColorsTheme.colPrimary, borderRadius: BorderRadius.circular(50)),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '${'Allow Permission'.tr} →',
                    style: semiBoldTextStyle(fontSize: dimen13, color: ColorsTheme.colWhite),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  controller.routeNavigator(0);
                },
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 20,bottom: 20),
                  child: Text(
                    'Not Now'.tr,
                    style: semiBoldTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ));
  }

}