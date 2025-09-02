import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/models/place_search_model.dart';

import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/shared/http_exception.dart';
import '../../infrastructure/shared/location_fun.dart';
import '../../infrastructure/shared/permission_fun.dart';

class SearchLocationController extends GetxController {
  var searchList = <String>[].obs;
  var searchText = ''.obs;

  var searchController = TextEditingController();
  var loadPlaceSearch = false.obs;

  var placeSearchList = <Predictions>[].obs;

  searchPlace(placeName, context) async {
    loadPlaceSearch.value = true;
    placeSearchList.clear();
    placeSearchList.refresh();
    try {
      PlaceSearchModel placeSearchModel = await DioClient.mapBase().funGetPlacesApi(placeName);
      if (placeSearchModel.status != null &&
          placeSearchModel.status!.isNotEmpty &&
          placeSearchModel.status!.toUpperCase() == 'OK') {
        placeSearchList.addAll(placeSearchModel.predictions!);
        placeSearchList.refresh();
        loadPlaceSearch.value = false;
      } else {
        loadPlaceSearch.value = false;
        //errorScreen(error:  'something_went_wrong'.tr);
      }
    } on CustomHttpException catch (exception) {
      loadPlaceSearch.value = false;
      //errorScreen(error:handleApiException(exception.code, exception.response, exception.exception, type: exception.type));
    } catch (exception) {
      loadPlaceSearch.value = false;
      //errorScreen(error:  'something_went_wrong'.tr);
    }
  }

  // current location
  checkAndAllowPermission() async {
    var locationStatus = await checkAndAllowLocationPermission();
    if (locationStatus == 1) {
      await checkLocationStatus(1);
    } else {
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

  checkLocationStatus(int status) async {
    if (status == -1) {
      await funOpenAppSettings();
    } else {
      // var loc = await getUserLocation();
      // var  address = loc['address'];
      // if (loc != null) {
      //   Get.back(result: [true, address]);
      // }else{
      //   Get.back(result: [false, status]);
      // }

      Get.back(result: [false, status]);
    }
  }
}
