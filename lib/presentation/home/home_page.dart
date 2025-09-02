import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/infrastructure/theme/text.theme.dart';
import 'package:good_grab/presentation/home/home_controller.dart';

import '../../res.dart';

class HomePage extends BaseView<HomeController> {
  HomePage({super.key});

  @override
  Widget body(BuildContext context) {
    return Obx(
      () => controller.itemList[controller.currentIndex.value]
    );
  }

  @override
  Widget? bottomNavigationBar() {
    return Obx(() =>
        BottomNavigationBar(
          selectedItemColor: ColorsTheme.colPrimary,
          unselectedItemColor: ColorsTheme.col8FA19C,
          backgroundColor: ColorsTheme.colF2FFFB,
          selectedLabelStyle: regularTextStyle(
            fontSize: dimen10,
            color: ColorsTheme.colPrimary,
          ),
          unselectedLabelStyle: regularTextStyle(
            fontSize: dimen10,
            color: ColorsTheme.col8FA19C,
          ),
          selectedFontSize: dimen10,
          unselectedFontSize: dimen10,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          iconSize: 0,
          elevation: 20,
          type: BottomNavigationBarType.shifting,
          currentIndex: controller.currentIndex.value,
          enableFeedback: false,
          onTap: (index) {
            controller.onSelectIndex(index);
          },
          items: [
            BottomNavigationBarItem(
                label: 'Home'.tr,
                icon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                  child: Image.asset(
                    Res.icHome,
                    height: 20,
                    width: 20,
                  ),
                ),
                activeIcon: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: ColorsTheme.colPrimary),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                  child: Image.asset(
                    Res.icHome,
                    height: 20,
                    width: 20,
                    color: Colors.white,
                  ),
                )),
            BottomNavigationBarItem(
                label: 'Map',
                icon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                  child: Image.asset(
                    Res.icMap,
                    height: 20,
                    width: 20,
                  ),
                ),
                activeIcon: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: ColorsTheme.colPrimary),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                  child: Image.asset(
                    Res.icMap,
                    height: 20,
                    width: 20,
                    color: Colors.white,
                  ),
                )),
            BottomNavigationBarItem(
                label: 'Orders',
                icon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                  child: Image.asset(
                    Res.icOrder,
                    height: 20,
                    width: 20,
                  ),
                ),
                activeIcon: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: ColorsTheme.colPrimary),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                  child: Image.asset(
                    Res.icOrder,
                    height: 20,
                    width: 20,
                    color: Colors.white,
                  ),
                )),
            BottomNavigationBarItem(
                label: 'Favourites',
                icon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                  child: Image.asset(
                    Res.icFav,
                    height: 20,
                    width: 20,
                  ),
                ),
                activeIcon: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: ColorsTheme.colPrimary),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                  child: Image.asset(
                    Res.icFav,
                    height: 20,
                    width: 20,
                    color: Colors.white,
                  ),
                )),
            BottomNavigationBarItem(
                label: 'Me',
                icon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                  child: Image.asset(
                    Res.icUser,
                    height: 20,
                    width: 20,
                  ),
                ),
                activeIcon: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: ColorsTheme.colPrimary),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                  child: Image.asset(
                    Res.icUser,
                    height: 20,
                    width: 20,
                    color: Colors.white,
                  ),
                ))
          ],
        ));
  }


}
