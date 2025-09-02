import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/infrastructure/shared/common_functions.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/presentation/change_number_email/change_number_email_controller.dart';
import 'package:lottie/lottie.dart';

import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/theme/text.theme.dart';
import '../../res.dart';

class ChangeNumberEmailPage extends BaseView<ChangeNumberEmailController>{
  ChangeNumberEmailPage({super.key});

  @override
  Widget body(BuildContext context) {
    return SafeArea(child: Column(
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
                    controller.title,
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
        Expanded(child: controller.screenType == 'number'?numberWidget(context):emailWidget(),),
        GestureDetector(
            onTap: () {
              if(controller.isFillColor.value){
                CommonFunction.keyboardDismiss(context);
                controller.isCheckNumberAndEmailApi();
              }
            },
            child: Obx(
                  () => Container(
                decoration: BoxDecoration(
                    color:  controller.isFillColor.value ? ColorsTheme.colPrimary : ColorsTheme.colSecondary,
                    borderRadius: BorderRadius.circular(50)),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 18),
                margin: const EdgeInsets.only(left: 28, right: 28, top: 40,bottom: 40),
                child: Text(
                  '${'Continue'.tr} →',
                  style: semiBoldTextStyle(
                      fontSize: dimen13,
                      color:  controller.isFillColor.value ? ColorsTheme.colWhite : ColorsTheme.colBlack),
                ),
              ),
            )),
      ],
    ));
  }

  numberWidget(context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 18, right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mobile Number'.tr,
            style: mediumTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
          ),
          Container(
            margin: const EdgeInsets.only(top: 15),
            decoration: BoxDecoration(
              border: Border.all(
                color: ColorsTheme.colSecondary,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                    onTap: () {
                      if(controller.countryList.isNotEmpty){
                        CommonFunction.keyboardDismiss(context);
                        countryPickerBottomSheet();
                      }
                    },
                    child: Obx(
                          () => Text(
                        '+${controller.selectedCountryCode.value}',
                        style: mediumTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                      ),
                    )),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    controller: controller.numberController,
                    onChanged: (text) {
                      if(text.isNotEmpty){
                        controller.isFillColor.value = true;
                      }
                      else{
                        controller.isFillColor.value = false;
                      }
                    },
                    maxLength: 15,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.only(bottom: 1.5),
                        counterText: '',
                        hintText: '9999999999',
                        hintStyle: mediumTextStyle(fontSize: dimen13, color: ColorsTheme.colHint)),
                    style: mediumTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  emailWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 18, right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email'.tr,
            style: mediumTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
          ),
          Container(
            margin: const EdgeInsets.only(top: 15),
            decoration: BoxDecoration(
              border: Border.all(
                color: ColorsTheme.colSecondary,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
            child: TextField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'h@gmail.com',
                  hintStyle: mediumTextStyle(fontSize: dimen13, color: ColorsTheme.colHint)),
              style: mediumTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
              onChanged: (text){
                if(text.isNotEmpty){
                  controller.isFillColor.value = true;
                }
                else{
                  controller.isFillColor.value = false;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  countryPickerBottomSheet() {
    Get.bottomSheet(StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Container(
          color: Colors.transparent,
          padding: const EdgeInsets.only(bottom: 0, left: 0, right: 0),
          child: Column(
            children: [
              const Spacer(),
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  decoration: BoxDecoration(color: ColorsTheme.colWhite, shape: BoxShape.circle),
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 20),
                  alignment: Alignment.center,
                  width: 40,
                  height: 40,
                  child: Image.asset(
                    Res.icCancel,
                    color: ColorsTheme.colPrimary,
                    width: 15,
                    height: 15,
                  ),
                ),
              ),
              Container(
                  height: Get.height / 2,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: const EdgeInsets.only(bottom: 10, top: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: ColorsTheme.colPrimary),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                            Image.asset(
                              Res.icSearch,
                              height: 20,
                              width: 20,
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                child: TextField(
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(20),
                                    ],
                                    controller: controller.searchController,
                                    autocorrect: true,
                                    decoration: InputDecoration(
                                        hintText: 'search_country_name'.tr,
                                        hintStyle: mediumTextStyle(fontSize: dimen14, color: ColorsTheme.colHint),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true),
                                    style: mediumTextStyle(fontSize: dimen14, color: ColorsTheme.colBlack),
                                    onChanged: (value) {
                                      controller.getSearchCountriesList(value);
                                    }),
                              ),
                            ),
                            Obx(
                                  () => Visibility(
                                visible: controller.isSearch.value ? true : false,
                                child: GestureDetector(
                                    onTap: () {
                                      controller.clearSearchData();
                                    },
                                    child: Image.asset(
                                      Res.icCancel,
                                      height: 15,
                                      width: 15,
                                    )),
                              ),
                            ),
                          ])),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                          child: Obx(() => controller.isSearch.value && controller.searchCountriesList.isNotEmpty
                              ? searchCountryListWidget()
                              : countryListWidget()
                          )
                      )
                    ],
                  )),
            ],
          ));
    }), isScrollControlled: true);
  }


  searchCountryListWidget() {
    return GetBuilder<ChangeNumberEmailController>(builder: (controller) {
      return Obx(() => controller.searchCountriesList.isNotEmpty
          ? ListView.separated(
        itemCount: controller.searchCountriesList.length,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              controller.selectSearchCode(index);
            },
            child: Container(
              margin: const EdgeInsets.only(top: 6,bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    controller.searchCountriesList[index].country.toString(),
                    style: regularTextStyle(fontSize: dimen14, color: Colors.black),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "( +${controller.searchCountriesList[index].dialingCode.toString()} )",
                    style: regularTextStyle(fontSize: dimen14, color: Colors.black),
                  )
                ],
              ),
            ),
          );
        }, separatorBuilder: (BuildContext context, int index) { return Divider(color: ColorsTheme.colPrimary.withOpacity(0.2)); },)
          : Align(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Lottie.asset(
                  Res.errorFoundNewJson,
                  width: 100,
                  height: 100
              ),
            ),
            Text(
              "no_country_found".tr,
              style: mediumTextStyle(fontSize: dimen14, color: Colors.black),
            ),
          ],
        ),
      ));
    });
  }

  countryListWidget() {
    return ListView.separated(
      itemCount: controller.countryList.length,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            controller.selectCountryCode(index);
          },
          child: Container(
            margin: const EdgeInsets.only(top: 6,bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  controller.countryList[index].country.toString(),
                  style: regularTextStyle(fontSize: dimen14, color: Colors.black),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "( +${controller.countryList[index].dialingCode.toString()} )",
                  style: regularTextStyle(fontSize: dimen14, color: Colors.black),
                )
              ],
            ),
          ),
        );
      }, separatorBuilder: (BuildContext context, int index) {
      return Divider(color: ColorsTheme.colPrimary.withOpacity(0.2));
    },);
  }

}