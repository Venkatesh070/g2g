import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/constants/app_constants.dart';
import 'package:good_grab/infrastructure/shared/pref_manager.dart';
import '../../infrastructure/firebase/dynamic_link_service.dart';
import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/shared/permission_fun.dart';


class SplashController extends GetxController with GetTickerProviderStateMixin{

  var width = (0.0).obs;
  late AnimationController animationController;
  late Animation<double> animation ;


  @override
  void onInit() {

    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));
    animation = CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    width.value = animation.value;
    animation.addListener((){
      width.value = animation.value*300;
      update();
    });
    animationController.forward();
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        changeScreen();
      }
    });
    super.onInit();
  }


  changeScreen() async{


    final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if(initialLink != null){
      DynamicLinkService().initDynamicLinks(initialLink);
    }
    else{
      var  isLoggedIn = await PrefManager.getBool(AppConstants.loggedIn);
      print('checking logged in $isLoggedIn');
      if(isLoggedIn){
        navigateScreen();
      }else{
        Get.offNamed(Routes.intro);
      }
    }

  }
  navigateScreen() async {
    var locationStatus = await getLocationPermissionStatus();
    var notificationStatus = await getNotificationPermissionStatus();
    if (locationStatus == 1 && notificationStatus == 1) {
      Get.offNamed(Routes.home, arguments: {'permission': 1});
    } else {
      Get.offNamed(Routes.allowPermission);
    }
  }
}
