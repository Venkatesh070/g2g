import 'package:get/get.dart';
import 'package:good_grab/infrastructure/shared/pref_manager.dart';

import 'package:location/location.dart';

import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/shared/permission_fun.dart';

class AllowPermissionController extends GetxController {

  LocationData? locationData;
  String? locationAddress;



  checkAndAllowPermission() async {
    var locationStatus = await checkAndAllowLocationPermission();
    if(locationStatus == 1){
      var notificationStatus = await checkAndAllowNotificationPermission();
      if(notificationStatus == 1) {
        await checkLocationStatus(1);
      }
      else{
        await checkLocationStatus(-1);
      }
    }
    else{
      await checkLocationStatus(-1);
    }
  }

  checkAndAllowLocationPermission() async {
    var locationServiceStatus = await getLocationServicePermissionStatus();
    var locationStatus = await getLocationPermissionStatus();

    if (!locationServiceStatus || locationStatus == 0) {
      locationStatus = await requestLocationPermission();
      if (locationStatus == 0) {
        locationStatus = await requestLocationPermission();
        if (locationStatus == -1 || locationStatus == 0) {
          return -1;
        } else {
          return 1;
        }
      }
      return locationStatus;
    }
    return locationStatus;
  }

  checkAndAllowNotificationPermission() async {
    var notificationStatus = await getNotificationPermissionStatus();

    if(notificationStatus == 0){
      notificationStatus = await requestNotificationPermission();
      if(notificationStatus == 1){
        return 1;
      }
      else{
        return -1;
      }
    }
    return notificationStatus;
  }

  checkLocationStatus(int status) async {
    if (status == -1) {
      await funOpenAppSettings();
    } else {
      routeNavigator(1);
    }
  }


  routeNavigator(int permission){
    Get.offAllNamed(Routes.home,arguments: {'permission' : permission});
  }


}
