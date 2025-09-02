import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/infrastructure/theme/text.theme.dart';
import 'package:good_grab/presentation/money_co2_saved/money_co2_saved_controller.dart';

import '../../infrastructure/shared/no_data_screen.dart';
import '../../res.dart';

class MoneyCO2SavedPage extends BaseView<MoneyCO2SavedController>{
  MoneyCO2SavedPage({super.key});


  @override
  Widget body(BuildContext context) {
    return SafeArea(child: Column(
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
        controller.screenFlag == 'money'?moneyWidget():co2Widget()
      ],
    ));
  }

  moneyWidget(){
    return Obx(() => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: ColorsTheme.colPrimary,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 18,vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 30,bottom: 10),
            child: Text(
              'Total Money Saved'.tr,
              style: regularTextStyle(fontSize: dimen15, color: ColorsTheme.colWhite),
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 15),
            child: Text(
              '${controller.unit}${controller.totalValue}',
              style: mediumTextStyle(fontSize: dimen32, color: ColorsTheme.colWhite),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Divider(
              color: ColorsTheme.colC4D9D4,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 18,right: 18,bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Image.asset(
                        Res.icRes,
                        width: 25,
                        height: 25,
                      ),
                    ),
                    Text(
                      'Magical Bag Saved'.tr,
                      style: regularTextStyle(fontSize: dimen12, color: ColorsTheme.colWhite),
                    ),
                  ],
                ),
                Text(controller.magicalBag.value.toString(),
                  style: semiBoldTextStyle(fontSize: dimen12, color: ColorsTheme.colWhite),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 18,right: 18,bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                          color: ColorsTheme.colD0F0BF,
                          shape: BoxShape.circle
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        controller.unit,
                        style: boldTextStyle(fontSize: dimen14, color: ColorsTheme.colPrimary),
                      ),
                    ),
                    Text(
                      'Original Value'.tr,
                      style: regularTextStyle(fontSize: dimen12, color: ColorsTheme.colWhite),
                    ),
                  ],
                ),
                Text(
                  '${controller.unit}${controller.originalValue.value.toString()}',
                  style: semiBoldTextStyle(fontSize: dimen12, color: ColorsTheme.colWhite),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 18,right: 18,bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                          color: ColorsTheme.colD0F0BF,
                          shape: BoxShape.circle
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        controller.unit,
                        style: boldTextStyle(fontSize: dimen14, color: ColorsTheme.colPrimary),
                      ),
                    ),
                    Text(
                      'You Paid'.tr,
                      style: regularTextStyle(fontSize: dimen12, color: ColorsTheme.colWhite),
                    ),
                  ],
                ),
                Text(
                  '${controller.unit}${controller.youPaidValue.value.toString()}',
                  style: semiBoldTextStyle(fontSize: dimen12, color: ColorsTheme.colWhite),
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }

  co2Widget(){
    return Expanded(
      child: SingleChildScrollView(
        child: Obx(() => Container(
          margin: const EdgeInsets.symmetric(horizontal: 18,vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: ColorsTheme.colPrimary,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                margin: const EdgeInsets.only(bottom: 20),
                width: Get.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            '${controller.totalCo2Saved}',
                            style: semiBoldTextStyle(fontSize: dimen27, color: ColorsTheme.colWhite),
                          ),
                        ),
                        Text(
                          'EQUICALENCE IN SAVED CO2e'.tr,
                          style: regularTextStyle(fontSize: dimen10, color: ColorsTheme.colWhite),
                        )
                      ],
                    ),
                    Image.asset(
                      Res.icProfileCo2,
                      width: 50,
                      height: 50,
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'co2_subtitle'.tr,
                  style: boldTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: ColorsTheme.colC4D9D4,
                        width: 1
                    ),
                    borderRadius: BorderRadius.circular(20)
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                margin: const EdgeInsets.only(bottom: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      child: Image.asset(
                        Res.icCo2E,
                        width: 45,
                        height: 45,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              '${controller.electricityValue.value} kWh',
                              style: boldTextStyle(fontSize: dimen13, color: ColorsTheme.colPrimary),
                            ),
                          ),
                          Text(
                            'Electricity'.tr,
                            style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: ColorsTheme.colC4D9D4,
                        width: 1
                    ),
                    borderRadius: BorderRadius.circular(20)
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                margin: const EdgeInsets.only(bottom: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      child: Image.asset(
                        Res.icCo2Charges,
                        width: 45,
                        height: 45,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              controller.smartPhoneChargeValue.value,
                              style: boldTextStyle(fontSize: dimen13, color: ColorsTheme.colPrimary),
                            ),
                          ),
                          Text(
                            'Full Smartphone Charges'.tr,
                            style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: ColorsTheme.colC4D9D4,
                        width: 1
                    ),
                    borderRadius: BorderRadius.circular(20)
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                margin: const EdgeInsets.only(bottom: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      child: Image.asset(
                        Res.icCo2Cup,
                        width: 45,
                        height: 45,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              controller.cupValue.value,
                              style: boldTextStyle(fontSize: dimen13, color: ColorsTheme.colPrimary),
                            ),
                          ),
                          Text(
                            'Cups of hot Coffee'.tr,
                            style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: ColorsTheme.colC4D9D4,
                        width: 1
                    ),
                    borderRadius: BorderRadius.circular(20)
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                margin: const EdgeInsets.only(bottom: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      child: Image.asset(
                        Res.icCo2Hot,
                        width: 45,
                        height: 45,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              controller.getTime(controller.showerValue.value),
                              style: boldTextStyle(fontSize: dimen13, color: ColorsTheme.colPrimary),
                            ),
                          ),
                          Text(
                            'time_to_hot'.tr,
                            style: regularTextStyle(fontSize: dimen11, color: ColorsTheme.colBlack),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),)
      ),
    );
  }

  noDataWidget(){
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: Get.height * 0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            noDataScreen(noDataImage: controller.screenFlag == 'money'?Res.icProfileMoney:Res.icProfileCo2,
              title:  'no_magical_title'.tr, subtitle: 'no_magical_subtitle'.tr,),
            GestureDetector(
                onTap: () {
                },
                child:Container(
                  decoration: BoxDecoration(
                      color: ColorsTheme.colPrimary,
                      borderRadius: BorderRadius.circular(50)),
                  alignment: Alignment.center,
                  width: 250,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  margin:  const EdgeInsets.only(left: 28,right:28,top: 20),
                  child: Text(
                    'Save your First Magical Bag'.tr,
                    style: semiBoldTextStyle(fontSize: dimen13, color: ColorsTheme.colWhite),
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }

}