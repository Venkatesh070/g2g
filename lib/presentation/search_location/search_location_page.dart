import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/infrastructure/shared/no_data_screen.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/presentation/search_location/search_location_controller.dart';

import '../../infrastructure/shared/common_functions.dart';
import '../../infrastructure/shared/custom_shimmer_widget.dart';
import '../../infrastructure/theme/text.theme.dart';
import '../../res.dart';

class SearchLocationPage extends BaseView<SearchLocationController> {
  SearchLocationPage({super.key});

  @override
  Color pageBackgroundColor() => ColorsTheme.colWhite;

  @override
  Widget body(BuildContext context) {
    return SafeArea(
        child: Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    'Add Location'.tr,
                    style: boldTextStyle(fontSize: dimen16, color: ColorsTheme.colBlack),
                  ),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                  color: ColorsTheme.colHint,
                ),
                borderRadius: BorderRadius.circular(32)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            margin: const EdgeInsets.only(top: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  Res.icSearch,
                  width: 18,
                  height: 18,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    child: TextField(
                      controller: controller.searchController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: 'Search location'.tr,
                        hintStyle: regularTextStyle(fontSize: dimen13, color: ColorsTheme.col8FA19C),
                      ),
                      style: regularTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                      onChanged: (value) {
                        controller.searchText.value = value;
                        EasyDebounce.debounce('searchLocation', const Duration(milliseconds: 700), () async {
                          await controller.searchPlace(value, context);
                        });
                      },
                    ),
                  ),
                ),
                Obx(
                  () => Visibility(
                    visible: controller.searchText.isNotEmpty,
                    child: InkWell(
                      onTap: () {
                        controller.searchText.value = '';
                        controller.searchController.text = '';
                        controller.placeSearchList.clear();
                        controller.placeSearchList.refresh();
                      },
                      child: Image.asset(
                        Res.icCancel,
                        width: 15,
                        height: 15,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Obx(
            () => Visibility(
              visible: controller.searchText.isEmpty,
              child: GestureDetector(
                onTap: () {
                  controller.checkAndAllowPermission();
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        Res.icCurrentLocation,
                        width: 35,
                        height: 35,
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: Text(
                          'Use my current location'.tr,//change by krishna
                          style: regularTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
              child: Container(
            margin: const EdgeInsets.only(top: 18, bottom: 18),
            child: Obx(() => controller.loadPlaceSearch.value
                ? ListView.builder(
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
                    })
                : controller.placeSearchList.isEmpty
                    ? SingleChildScrollView(
                        child: Container(
                            margin: EdgeInsets.symmetric(vertical: Get.height * 0.2),
                            child: noDataScreen(title: 'No Search Data')))
                    : ListView.separated(
                        itemCount: controller.placeSearchList.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              CommonFunction.keyboardDismiss(context);
                              Get.back(result: [true, controller.placeSearchList[index].description]);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 6, bottom: 6),
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Image.asset(
                                      Res.icLocation,
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      controller.placeSearchList[index].description ?? '',
                                      style: regularTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            color: ColorsTheme.colSecondary,
                          );
                        },
                      )),
          ))
        ],
      ),
    ));
  }
}
