import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/infrastructure/theme/text.theme.dart';
import 'package:good_grab/presentation/notification/notification_controller.dart';

import '../../infrastructure/shared/common_functions.dart';
import '../../infrastructure/shared/custom_shimmer_widget.dart';
import '../../infrastructure/shared/no_data_screen.dart';
import '../../res.dart';

class NotificationPage extends BaseView<NotificationController> {
  NotificationPage({super.key});

  @override
  Widget body(BuildContext context) {
    return SafeArea(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.arrow_back,
                  size: 25,
                  color: ColorsTheme.colBlack,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Notifications'.tr,
                    style: boldTextStyle(fontSize: dimen16, color: ColorsTheme.colBlack),
                  ),
                ),
              ),
              const SizedBox(
                width: 30,
              )
            ],
          ),
        ),
        Expanded(
            child: Obx(
          () => controller.isLoadingData.value
              ? Container(
                  margin: const EdgeInsets.only(left: 18, right: 18, top: 8, bottom: 8),
                  child: ListView.builder(
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          leading: const CustomShimmerWidget.rectangular(
                            height: 64,
                            width: 64,
                            borderRadius: 16,
                          ),
                          title: Align(
                            alignment: Alignment.centerLeft,
                            child: CustomShimmerWidget.rectangular(
                              height: 16,
                              width: Get.size.width * 0.3,
                            ),
                          ),
                          subtitle: const CustomShimmerWidget.rectangular(height: 14),
                        );
                      }),
                )
              : controller.notificationData.isEmpty
                  ? SingleChildScrollView(
                      child: Container(
                          margin: EdgeInsets.symmetric(vertical: Get.height * 0.2),
                          child: noDataScreen(noDataImage: Res.icRestaurant, title: '${'no_data_found'.tr}?'.tr)),
                    )
                  : Container(
            margin: const EdgeInsets.only(left: 18, right: 18, top: 8, bottom: 8),
            child: ListView.separated(
              controller: controller.pagingListController,
              itemCount: controller.notificationData.length+1,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if(index == controller.notificationData.length){
                  return buildProgressIndicator();
                }else {
                  return Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            controller.notificationData.value[index].title.toString(),
                            style: boldTextStyle(fontSize: dimen12, color: ColorsTheme.colBlack),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            controller.notificationData.value[index].message.toString(),
                            style: regularTextStyle(fontSize: dimen10, color: ColorsTheme.colBlack),
                          ),
                        ),
                        Text(
                          '${CommonFunction.dateTimeFormat(controller.notificationData.value[index].createdAt!)}',
                          style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                        )
                      ],
                    ),
                  );
                }
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  color: ColorsTheme.colA3A8A4,
                );
              },
            ),
          )
        ))
      ],
    ));
  }

  buildProgressIndicator() {
    return  Obx(()=> Padding(
      padding: const EdgeInsets.all(8.0),
      child:  Center(
        child:  Opacity(
          opacity: controller.isPageLoad.value ? 1.0 : 0.0,
          child: CircularProgressIndicator( color: ColorsTheme.colPrimary,),
        ),
      ),
    ));
  }
}
