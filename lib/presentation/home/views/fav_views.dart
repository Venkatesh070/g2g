import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/infrastructure/theme/text.theme.dart';
import 'package:good_grab/presentation/home/home_controller.dart';

import '../../../infrastructure/navigation/routes.dart';
import '../../../infrastructure/shared/common_functions.dart';
import '../../../infrastructure/shared/custom_shimmer_widget.dart';
import '../../../infrastructure/shared/no_data_screen.dart';
import '../../../res.dart';

class FavView extends GetView<HomeController> {
  const FavView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 18, right: 18, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: Text(
                'Favourites',
                style: boldTextStyle(fontSize: dimen21, color: ColorsTheme.colBlack),
              ),
            ),
            Expanded(
              child: Obx(() => controller.favLoader.value
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
                  : controller.favList.isEmpty
                      ? SingleChildScrollView(
                          child: Container(
                              margin: EdgeInsets.symmetric(vertical: Get.height * 0.2),
                              child: Column(
                                children: [
                                  noDataScreen(
                                      noDataImage: Res.icFav1,
                                      title: 'no_fav_title'.tr,
                                      subtitle: 'no_fav_subtitle'.tr),
                                  GestureDetector(
                                      onTap: () {
                                        controller.onSelectIndex(0);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: ColorsTheme.colPrimary, borderRadius: BorderRadius.circular(50)),
                                        alignment: Alignment.center,
                                        width: 200,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        margin: const EdgeInsets.only(left: 28, right: 28, top: 25),
                                        child: Text(
                                          'Add favorites'.tr,
                                          style: semiBoldTextStyle(fontSize: dimen13, color: ColorsTheme.colWhite),
                                        ),
                                      )),
                                ],
                              )),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          controller: controller.pagingListController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.favList.length+1,
                          itemBuilder: (context, index) {
                            if (index == controller.favList.length) {
                              return controller.buildProgressIndicator();
                            } else {
                              return GestureDetector(
                                onTap: () async {

                                  if (controller.favList[index].quantity != 0) {
                                    var result = await Get.toNamed(Routes.homeDetails, arguments: {
                                      'resId': controller.favList[index].restaurantId,
                                      'currency': controller.currency.value,
                                      'user_id': controller.userId.value
                                    });
                                    if (result != null && result) {
                                      controller.favLoader.value = true;
                                      controller.currentPage.value = 1;
                                      controller.favList.clear();
                                      controller.getFavData();
                                    }
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: Stack(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(right: 15),
                                                width: 100,
                                                height: 100,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(16),
                                                  child: controller.favList[index].restaurantImage == null
                                                      ? Image.asset(
                                                          Res.icDummyBanner,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Image.network(controller.favList[index].restaurantImage!,
                                                          fit: BoxFit.cover, errorBuilder: (context, obj, stackTrace) {
                                                          return Image.asset(
                                                            Res.icDummyBanner,
                                                            fit: BoxFit.cover,
                                                          );
                                                        }),
                                                ),
                                              ),
                                              Positioned(
                                                top: 5,
                                                right: 20,
                                                child: InkWell(
                                                  onTap: () {
                                                    controller.addFav(index, 'fav');
                                                  },
                                                  child: controller.favList[index].isLiked == "0"
                                                      ? Container(
                                                          decoration: const BoxDecoration(
                                                              color: Colors.white, shape: BoxShape.circle),
                                                          width: 30,
                                                          height: 30,
                                                          alignment: Alignment.center,
                                                          child: Image.asset(
                                                            Res.icHeart,
                                                            width: 18,
                                                            height: 18,
                                                          ))
                                                      : Image.asset(
                                                          Res.icFillHeart,
                                                          width: 30,
                                                          height: 30,
                                                        ),
                                                ),
                                              ),
                                              Positioned(
                                                  bottom: 5,
                                                  left: 5,
                                                  child: ClipOval(
                                                    child: controller.favList[index].restaurantCoverImage == null
                                                        ? Image.asset(
                                                            Res.icDummyLogo,
                                                            width: 35,
                                                            height: 35,
                                                          )
                                                        : Image.network(controller.favList[index].restaurantCoverImage!,
                                                        width: 45,
                                                        height: 45, errorBuilder: (context, obj, stackTrace) {
                                                            return Image.asset(
                                                              Res.icDummyLogo,
                                                              width: 45,
                                                              height: 45,
                                                            );
                                                          }),
                                                  ))
                                            ],
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${controller.favList[index].restaurantName!} - ${controller.favList[index].restaurantLocation!}',
                                                  style:
                                                      semiBoldTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
                                                  maxLines: 2,
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(top: 5),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets.only(right: 5),
                                                        child: Text(
                                                          '${controller.favList[index].distance!} km',
                                                          style: mediumTextStyle(
                                                              fontSize: dimen12, color: ColorsTheme.colBlack),
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsets.only(right: 5),
                                                        child: Text(
                                                          '${controller.currency.value}${controller.favList[index].finalPrice!}',
                                                          style: boldTextStyle(
                                                              fontSize: dimen15, color: ColorsTheme.colPrimary),
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${controller.currency.value}${controller.favList[index].offerPrice!}',
                                                        style: TextStyle(
                                                            fontSize: dimen11,
                                                            color: ColorsTheme.col8FA19C,
                                                            fontWeight: FontWeight.w400,
                                                            decorationColor: ColorsTheme.col8FA19C,
                                                            decoration: TextDecoration.lineThrough),
                                                        maxLines: 2,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(top: 10),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      // Expanded(
                                                      //     child: Text(
                                                      //   '${'Total Magic Bags'.tr}: ${controller.favList[index].quantity!} ${'left'.tr}',
                                                      //   style: regularTextStyle(
                                                      //       fontSize: dimen11, color: ColorsTheme.colBlack),
                                                      //   maxLines: 2,
                                                      // )),
                                                      Expanded(child: Container()),
                                                      Row(
                                                        children: [
                                                          Visibility(
                                                            visible: controller.favList[index].isVeg == 2 ||
                                                                controller.favList[index].isVeg == 0,
                                                            child: Image.asset(
                                                              Res.icVeg,
                                                              width: 20,
                                                              height: 20,
                                                            ),
                                                          ),
                                                          Visibility(
                                                            visible: controller.favList[index].isVeg == 1 ||
                                                                controller.favList[index].isVeg == 0,
                                                            child: const SizedBox(
                                                              width: 10,
                                                            ),
                                                          ),
                                                          Visibility(
                                                            visible: controller.favList[index].isVeg == 1 ||
                                                                controller.favList[index].isVeg == 0,
                                                            child: Image.asset(
                                                              Res.icNonVeg,
                                                              width: 20,
                                                              height: 20,
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: false, // removed by vijay date 20 Mar Approved by client
                                                  child: Container(
                                                    margin: const EdgeInsets.only(top: 5),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              color: ColorsTheme.colPrimary,
                                                              borderRadius: BorderRadius.circular(16)),
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                          margin: const EdgeInsets.only(right: 5),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                margin: const EdgeInsets.only(right: 5),
                                                                child: Icon(
                                                                  Icons.star,
                                                                  color: ColorsTheme.colWhite,
                                                                  size: 14,
                                                                ),
                                                              ),
                                                              Text(
                                                                controller.favList[index].rating!,
                                                                style: regularTextStyle(
                                                                    fontSize: dimen10, color: ColorsTheme.colWhite),
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            '${CommonFunction.formatPickupTime(controller.favList[index].openTime!)} to ${CommonFunction.formatPickupTime(controller.favList[index].closeTime!)}',
                                                            style: regularTextStyle(
                                                                fontSize: dimen11, color: ColorsTheme.col8FA19C),
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        child: controller.favList[index].quantity == 0
                                            ? Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(16),
                                                    color: ColorsTheme.colWhite.withOpacity(0.5)),
                                              )
                                            : Container(),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        width: Get.width * 0.66,
                                        child: controller.favList[index].quantity == 0
                                            ? Container(
                                                decoration: BoxDecoration(
                                                    color: ColorsTheme.colD0F0BF,
                                                    borderRadius: BorderRadius.circular(16)),
                                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                                child: Text.rich(TextSpan(children: [
                                                  TextSpan(
                                                    text: 'sold_out'.tr,
                                                    style: regularTextStyle(
                                                        fontSize: dimen11, color: ColorsTheme.colBlack),
                                                  ),
                                                  // TextSpan(
                                                  //   text: ' Tomorrow.',
                                                  //   style: semiBoldTextStyle(
                                                  //       fontSize: dimen11, color: ColorsTheme.colBlack),
                                                  // )
                                                ])),
                                              )
                                            : Container(),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider(
                              color: ColorsTheme.colC4D9D4,
                            );
                          },
                        )),
            ),
            // Obx(() => Visibility(
            //       visible: controller.isPageLoad.value ? true : false,
            //       child: Container(
            //         height: 50,
            //         alignment: Alignment.center,
            //         child: const CircularProgressIndicator(),
            //       ),
            //     ))
          ],
        ),
      ),
    );
  }
}
