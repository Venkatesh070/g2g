import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:good_grab/infrastructure/constants/app_constants.dart';
import 'package:good_grab/infrastructure/models/fav_model.dart';
import 'package:good_grab/infrastructure/models/filter_model.dart';
import 'package:good_grab/infrastructure/models/home_model.dart';
import 'package:good_grab/infrastructure/models/order_model.dart';
import 'package:good_grab/infrastructure/navigation/routes.dart';
import 'package:good_grab/infrastructure/shared/common_functions.dart';
import 'package:good_grab/infrastructure/shared/pref_manager.dart';
import 'package:good_grab/infrastructure/shared/progress_dialog.dart';
import 'package:good_grab/presentation/home/views/fav_views.dart';
import 'package:good_grab/presentation/home/views/home_view.dart';
import 'package:good_grab/presentation/home/views/map_view.dart';
import 'package:good_grab/presentation/home/views/me_view.dart';
import 'package:good_grab/presentation/home/views/orders_view.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../../infrastructure/models/api_response_model.dart';
import '../../infrastructure/models/earning_model.dart';
import '../../infrastructure/models/user_home_model.dart';
import '../../infrastructure/models/user_model.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/shared/app_exception_handle.dart';
import '../../infrastructure/shared/error_screen.dart';
import '../../infrastructure/shared/http_exception.dart';
import '../../infrastructure/shared/location_fun.dart';
import '../../infrastructure/shared/permission_fun.dart';
import '../../infrastructure/theme/colors.theme.dart';
import '../../infrastructure/theme/text.theme.dart';
import '../../res.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs;
  var itemList = [].obs;

// address data
  var permissionAllow = 0.obs;
  var isSearchLocation = false.obs;
  var address = ''.obs;
  var lat = (0.0).obs;
  var lng = (0.0).obs;

  // final Completer<GoogleMapController> mapController = Completer<GoogleMapController>();
  GoogleMapController? mapController;

// home
  var homeLoader = false.obs;
  var homeList = <RestaurantList>[].obs;
  var mapHomeList = <RestaurantList>[].obs;
  var bannerHomeList = <Banners>[].obs;
  var orderHomeList = <Orders>[].obs;
  var cartHomeList = <CartList>[].obs;
  var currentBannerIndex = 0.obs;
  var isOrderInstruction = false.obs;

//video player
//   late VideoPlayerController videoPlayerController;
  var isVideoPause = true.obs;
  var isVideoLoad = false.obs;
  var videoType = '';
  var videoPath = ''.obs;

  //paging

  var totalPage = 1.obs;
  var currentPage = 1.obs;
  var isPageLoad = false.obs;
  var pagingListController = ScrollController();

  // var orderListController = ScrollController();
  // var favListController = ScrollController();

// search
  var searchText = ''.obs;
  var searchController = TextEditingController();

// filter
  var isFilter = false.obs;
  var isAppliedFilter = false.obs;
  var isMapAppliedFilter = false.obs;
  var foodPrefList = <FoodPrefrence>[].obs;
  var foodTypeList = <FoodType>[].obs;
  var pickupDayList = <String>[].obs;
  var pickupStockList = <String>[].obs;

  var mapFoodPrefList = <FoodPrefrence>[].obs;
  var mapFoodTypeList = <FoodType>[].obs;
  var mapPickupDayList = <String>[].obs;
  var mapPickupStockList = <String>[].obs;

  var selectedPickupDay = Rx(-1);
  var selectedPickupDayMap = Rx(-1);
  var selectedStockAvailability = Rx(-1);
  var selectedStockAvailabilityMap = Rx(-1);

  var pickupDistanceMax = (0.0).obs;
  var selectedPickupDistance = (0.0).obs;

  var pickupMinTime = (0.0).obs;
  var pickupMaxTime = (0.0).obs;
  var pickupSelectMinTime = (0.0).obs;
  var pickupSelectMaxTime = (0.0).obs;
  var isPickupHoursList = false.obs;

  DateTime? hOnly;
  DateTime? pHOnly;

  // orders
  var orderLoader = false.obs;
  var orderList = <OrdersList>[].obs;
  var orderCurrentPage = 1.obs;
  var orderTotalPage = 1.obs;
  var totalOrderItem = 0.obs;

  //fav
  var favLoader = false.obs;
  var favList = <FavouriteList>[].obs;
  var favCurrentPage = 1.obs;
  var favTotalPage = 1.obs;

  // me
  var isLogOut = false.obs;
  var appVersion = ''.obs;
  var currency = '₹'.obs;
  var moneySaved = (0.0).obs;
  var money = '0'.obs;

  // var moneySaved = (0.0).obs;
  var co2Saved = '0'.obs;
  var isLoggedIn = false.obs;
  var userId = Rx(-1);
  var userName = ''.obs;
  var userNumber = ''.obs;
  var userCountryCode = ''.obs;
  var userProfile = ''.obs;

  var markerImage = Rx<Uint8List>(Uint8List(0));
  var markerSets = Rx(<Marker>{});
  ClusterManager? manager;
  var markers = <Marker>[].obs;
  Timer? _debounce;
  var isVideoInitialize = false.obs;

  @override
  void onInit() {
    listScrollListener();
    itemList.value = [
      const HomeView(),
      const MapView(),
      const OrdersView(),
      const FavView(),
      const MeView()
    ];
    permissionAllow.value = Get.arguments['permission'];
    Future.delayed(Duration.zero, () async {
      await getUserData();
      markerImage.value = await getBytesFromAsset(Res.icLocation, 100, 100);
    });

    // manager = _initClusterManager([PicCluster(name: 'Test_15', latLng: LatLng(0.0, 0.0))]);
    super.onInit();
  }

  onSelectIndex(index) async {
    onBannerVideoPlayerDispose();
    if (index == 0) {
      onSelectHomeMenu(index);
    } else if (index == 1) {
      onBannerVideoPlayerDispose();
      onSelectHomeMenu(index);
    } else if (index == 2) {
      onBannerVideoPlayerDispose();
      if (isLoggedIn.value) {
        currentIndex.value = index;
        orderLoader.value = true;
        currentPage.value = 1;
        orderList.clear();
        getOrdersList();
        Future.delayed(const Duration(milliseconds: 500), () {
          orderLoader.value = false;
        });
      } else {
        loginBottomSheet();
      }
    } else if (index == 3) {
      onBannerVideoPlayerDispose();
      if (isLoggedIn.value) {
        currentIndex.value = index;
        favLoader.value = true;
        currentPage.value = 1;
        favList.clear();
        await getFavData();
      } else {
        loginBottomSheet();
      }
    } else if (index == 4) {
      onBannerVideoPlayerDispose();
      currentIndex.value = index;
      if (isLoggedIn.value) {
        await getMyProfile();
      }
    } else {
      currentIndex.value = index;
    }
  }

  onSelectHomeMenu(index) {
    currentIndex.value = index;
    currentPage.value = 1;
    if (permissionAllow.value == 1) {
      Future.delayed(Duration.zero, () async {
        homeLoader.value = true;
        await getAddress();
      });
    } else {
      homeLoader.value = false;
    }
  }

  onBannerVideoPlayerDispose() {
    if (bannerHomeList.isNotEmpty) {
      if (bannerHomeList[currentBannerIndex.value].videoPlayerController !=
          null) {
        bannerHomeList[currentBannerIndex.value]
            .videoPlayerController!
            .dispose();
      }
    }
  }

  ///paging
  listScrollListener() {
    //Before managed by different controller in orderListController and favListController and now manage on single controller
    pagingListController.addListener(() {
      if (pagingListController.position.pixels ==
          pagingListController.position.maxScrollExtent) {
        isPageLoad.value = true;
        loadNextPage();
      }
    });
  }

  void loadNextPage() {
    if (totalPage.value != currentPage.value) {
      currentPage.value = currentPage.value + 1;
      if (currentIndex.value == 0 && !isSearchLocation.value) {
        getPHomeData();
      } else if (currentIndex.value == 2) {
        getOrdersList();
      } else if (currentIndex.value == 3) {
        getFavData();
      }
      // markers.refresh();
    } else {
      isPageLoad.value = false;
    }
  }

  ///starting of map and cluster
  void onMapCreated(GoogleMapController _cntlr) {
    mapController?.setMapStyle('''
        [
  {
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#f5f5f5"
          }
        ]
  },
  {
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
  },
  {
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
  },
  {
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#f5f5f5"
          }
        ]
  },
  {
        "featureType": "administrative.land_parcel",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#bdbdbd"
          }
        ]
  },
  {
        "featureType": "poi",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#eeeeee"
          }
        ]
  },
  {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
  },
  {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#e5e5e5"
          }
        ]
  },
  {
        "featureType": "poi.park",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
  },
  {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#ffffff"
          }
        ]
  },
  {
        "featureType": "road.arterial",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
  },
  {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#dadada"
          }
        ]
  },
  {
        "featureType": "road.highway",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
  },
  {
        "featureType": "road.local",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
  },
  {
        "featureType": "transit.line",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#e5e5e5"
          }
        ]
  },
  {
        "featureType": "transit.station",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#eeeeee"
          }
        ]
  },
  {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#c9c9c9"
          }
        ]
  },
  {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
  }
]
        ''');
    mapController = _cntlr;
    manager?.setMapId(mapController!.mapId);
    setPinedMarker();
  }

  setPinedMarker() {
    for (int i = 0; i < homeList.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId(homeList[i].latitude.toString()),
          position: LatLng(
              double.parse((homeList[i].latitude ?? 0.0).toString()),
              double.parse((homeList[i].longitude ?? 0.0).toString())),
          visible: true,
          onTap: () {},
          infoWindow: InfoWindow(title: homeList[i].restaurantName.toString()),
          icon:
              // mapList[i]["type"] == "flag"
              //     ? BitmapDescriptor.fromBytes(markerImageFlag.value) :
              BitmapDescriptor.fromBytes(markerImage.value),
        ),
      );

      markers.refresh();
    }

    // isLoading.value = false;

    print("pinedmarker ${markers.value}");
  }

  Future<Uint8List> getBytesFromAsset(
      String path, int width, int height) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width, targetHeight: height);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  // ClusterManager _initClusterManager(items) {
  //   print('cluster initialize');
  //
  //   return ClusterManager<PicCluster>(items, _updateMarkers,
  //       markerBuilder: _markerBuilder,
  //       levels: [1, 4.25, 6.75, 8.25, 11.5, 14.5, 16.0, 16.5, 20.0]);
  // }

  void _updateMarkers(Set<Marker> markers) {
    log('Updated_markers ${markers.length}');
    markerSets.value = markers;
  }

  Future<Marker> Function(Cluster<PicCluster>) get _markerBuilder =>
      (cluster) async {
        print('map marker updated: ${cluster.count}: ${cluster.isMultiple}');
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () async {
            print('----newCluster ${cluster.isMultiple}: ${cluster.location}');
            print('zoom level: ${await mapController!.getZoomLevel()}');
            //manager.updateMap();
            if (cluster.isMultiple) {
              mapController!.animateCamera(CameraUpdate.zoomIn());
            }

            cluster.items.forEach((p) => print(p));
          },
          infoWindow: cluster.isMultiple
              ? const InfoWindow()
              : InfoWindow(title: cluster.items.single.name),
          icon: await _getMarkerBitmap(cluster.isMultiple ? 85 : 55,
              text: cluster.isMultiple ? cluster.count.toString() : null),
        );
      };

  Future<BitmapDescriptor> _getMarkerBitmap(int size, {String? text}) async {
    if (kIsWeb) size = (size / 2).floor();
    var height = size;
    var width = size / 1.7;
    Uint8List markerIcon;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    // final Paint paint = Paint()..color = const Color(0xff012D3A);
    final Paint paint = Paint()..color = ColorsTheme.colPrimary;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: ui.TextDirection.ltr);
      //TextPainter painter = TextPainter(textDirection: TextDirection.LTR??);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: int.parse(text.toString()) > 9 ? size / 4 : size / 2,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.textAlign = TextAlign.center;
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
      final img = await pictureRecorder.endRecording().toImage(size, size);
      final data =
          await img.toByteData(format: ui.ImageByteFormat.png) as ByteData;
      return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
    } else {
      // ByteData data = await rootBundle.load(Res.icLocation);
      // ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: height.round());
      // ui.FrameInfo fi = await codec.getNextFrame();
      // markerIcon = (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
      return await BitmapDescriptor.fromBytes(markerImage.value);
    }
  }

  ///end of map

  getUserData() async {
    homeLoader.value = true;
    isLoggedIn.value = await PrefManager.getBool(AppConstants.loggedIn);
    if (isLoggedIn.value) {
      getUpdatedUserData();
    } else {
      userName.value = 'Guest';
    }
    appVersion.value = await CommonFunction.getAppVersion();
    homeList.clear();
    await setInitData();
  }

  getUpdatedUserData() async {
    var currentUser = await PrefManager.getUser();
    if (currentUser != null) {
      userId.value = currentUser.id!;

      // moneySaved.value = currentUser.savedMoney!;
      // money.value = NumberFormat.compact().format(moneySaved.value);
      // // co2Saved.value = currentUser.co2!;
      // if (currentUser.co2! < 100) {
      //   co2Saved.value = "${currentUser.co2!.toStringAsFixed(2)} kg";
      // } else if (currentUser.co2! >= 100 && currentUser.co2! < 1000) {
      //   var quental = currentUser.co2! / 100;
      //   co2Saved.value = "${quental.toStringAsFixed(2)} Q";
      // } else {
      //   var ton = currentUser.co2! / 1000;
      //   co2Saved.value = "${ton.toStringAsFixed(2)} Q";
      // }
      // print('money ${moneySaved.value} ${co2Saved.value}');
      userName.value = currentUser.username ?? 'User';
      userNumber.value = currentUser.mobile ?? '';
      userCountryCode.value = currentUser.countryCode ?? '';
      userProfile.value = currentUser.profile ?? '';
    } else {
      userName.value = 'Guest';
    }
  }

  getAddress() async {
    var loc = await getUserLocation();
    if (isSearchLocation.value) {
      var locationData = await getAddressLatLng(address.value);
      if (locationData != null) {
        lat.value = locationData['lat'];
        lng.value = locationData['lng'];
      } else {
        await geoCodingLatLongPlace(address.value);
      }
    } else {
      if (loc != null) {
        var locationData = loc['location'];
        address.value = loc['address'];
        lat.value = locationData!.latitude;
        lng.value = locationData!.longitude;
      }
    }
    await updateLocation();
  }

  geoCodingLatLongPlace(address) async {
    try {
      var response = await DioClient.mapBase().funGetGeoCodeApi(address);
      if (response['status'] != null &&
          response['status']!.isNotEmpty &&
          response['status']!.toUpperCase() == 'OK' &&
          response['results'] != null &&
          response['results']!.isNotEmpty &&
          response['results']![0]['geometry'] != null &&
          response['results']![0]['geometry']!['location'] != null) {
        lat.value = response['results']![0]['geometry']!['location']!['lat'];
        lng.value = response['results']![0]['geometry']!['location']!['lng'];
      }
    } on CustomHttpException catch (exception) {
      print("sdfdo ${exception}");
    } catch (exception) {
      print("sdfdo ${exception}");
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
      var result = await funOpenAppSettings();
    } else {
      permissionAllow.value = 1;
      setInitData();
    }
  }

  updateLocation() async {
    isSearchLocation.value = false;
    try {
      var deviceId = await PrefManager.getString(AppConstants.deviceId);
      Map<String, dynamic> params = {
        'latitude': lat.value,
        'longitude': lng.value,
        "location": address.value,
        "device_id": deviceId,
      };
      await DioClient.base().funUpdateLocationApi(params);
      if (currentIndex.value == 0) {
        pagingListController.jumpTo(0);
        await getHomeData();
      } else {
        await getMapData();
      }
    } on CustomHttpException catch (exception) {
      homeLoader.value = false;
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
    } catch (exception) {
      homeLoader.value = false;
      debugPrint(exception.toString());
    }
  }

  searchLocation() async {
    var result = await Get.toNamed(Routes.searchLocation);
    if (result != null) {
      isSearchLocation.value = result[0];
      if (isSearchLocation.value) {
        address.value = result[1];
      } else {
        permissionAllow.value = result[1];
        address.value = '';
      }
      homeLoader.value = true;
      await getAddress();
    }
  }

  // home
  setInitData() {
    if (permissionAllow.value == 1 || isSearchLocation.value) {
      Future.delayed(Duration.zero, () async {
        await getFilterData();
        currentPage.value = 1;
        homeLoader.value = true;
        await getAddress();
      });
    } else {
      homeLoader.value = false;
    }
  }

  initializeVideo() {
    for (int index = 0; index < bannerHomeList.length; index++) {
      if (bannerHomeList[index].mediaType.toString().trim() == "video") {
        try {
          debugPrint('initializeVideo: ${bannerHomeList[index].media!.trim()}');
          debugPrint(bannerHomeList[index].mediaType.toString().trim());
          print("videoplayerr${bannerHomeList[index].media!.trim()}");
          VoidCallback? listener;

          bannerHomeList[index].videoPlayerController =
              VideoPlayerController.network(bannerHomeList[index].media!.trim())
                ..initialize().then((_) {
                  isVideoInitialize.value = true;
                  bannerHomeList.refresh();
                  debugPrint(
                      'now initialize:${bannerHomeList[index].videoPlayerController}');

                  listener = () {
                    debugPrint('Video start');
                    debugPrint(
                        "video position ${bannerHomeList[index].videoPlayerController!.value.position.toString()}");

                    if (bannerHomeList[index]
                            .videoPlayerController!
                            .value
                            .position ==
                        bannerHomeList[index]
                            .videoPlayerController!
                            .value
                            .duration) {
                      bannerHomeList[index]
                          .videoPlayerController!
                          .seekTo(Duration.zero);
                      isVideoPause.value = true;
                      bannerHomeList.refresh();
                      debugPrint('Video Completed');
                    }
                  };

                  bannerHomeList[index]
                      .videoPlayerController!
                      .addListener(listener!);
                });
        } catch (e) {
          debugPrint('error:${e}');
        }
      }
    }
  }

  onTapVideoPause() {
    print("play_start ${isVideoPause.value}");
    if (isVideoPause.value) {
      bannerHomeList[currentBannerIndex.value].videoPlayerController!.play();
    } else {
      bannerHomeList[currentBannerIndex.value].videoPlayerController!.pause();
    }
    isVideoPause.value = !isVideoPause.value;
  }

  @override
  void dispose() {
    bannerHomeList[currentBannerIndex.value].videoPlayerController!.dispose();
    super.dispose();
  }

  getFilterData() async {
    isFilter.value = false;
    try {
      ApiResponseModel<FilterModel> filterModel =
          await DioClient.base().funFiltersApi();
      if (filterModel.success! &&
          filterModel.data != null &&
          filterModel.data!.filters != null) {
        foodTypeList.clear();
        foodPrefList.clear();
        pickupDayList.clear();
        pickupStockList.clear();
        foodTypeList.addAll(filterModel.data!.filters!.foodType!);
        foodPrefList.addAll(filterModel.data!.filters!.foodPrefrence!);
        mapFoodTypeList.addAll(filterModel.data!.filters!.foodType!);
        mapFoodPrefList.addAll(filterModel.data!.filters!.foodPrefrence!);
        pickupDistanceMax.value =
            double.parse(filterModel.data!.filters!.distanceRange ?? "0");
        if (filterModel.data!.filters!.pickupTime != null) {
          isPickupHoursList.value = true;
          var currentTime = DateTime.now();
          hOnly =
              DateTime(currentTime.year, currentTime.month, currentTime.day, 0);
          pHOnly = DateTime(
              currentTime.year, currentTime.month, currentTime.day, 23, 59);
          pickupMinTime.value = hOnly!.millisecondsSinceEpoch.toDouble();
          pickupSelectMinTime.value = hOnly!.millisecondsSinceEpoch.toDouble();
          pickupMaxTime.value = pHOnly!.millisecondsSinceEpoch.toDouble();
          pickupSelectMaxTime.value = pHOnly!.millisecondsSinceEpoch.toDouble();
        }

        // client want to remove 27 Feb

        // pickupDayList.value = [
        //   'Today'.tr,
        //   'Tomorrow'.tr,
        // ];
        // pickupStockList.value = [
        //   'Out of Stock'.tr,
        //   'In Stock'.tr,
        // ];
        // mapPickupDayList.value = [
        //   'Today'.tr,
        //   'Tomorrow'.tr,
        // ];
        // mapPickupStockList.value = [
        //   'Out of Stock'.tr,
        //   'In Stock'.tr,
        // ];
        isFilter.value = true;
      } else {}
    } on CustomHttpException catch (exception) {
      isFilter.value = false;
      debugPrint(exception.toString());
    } catch (exception) {
      isFilter.value = false;
      debugPrint(exception.toString());
    }
  }

  String toHHmmss(Duration duration) {
    var microseconds = duration.inMicroseconds;

    var hours = microseconds ~/ Duration.microsecondsPerHour;
    microseconds = microseconds.remainder(Duration.microsecondsPerHour);

    if (microseconds < 0) microseconds = -microseconds;

    var minutes = microseconds ~/ Duration.microsecondsPerMinute;
    microseconds = microseconds.remainder(Duration.microsecondsPerMinute);

    var minutesPadding = minutes < 10 ? "0" : "";

    var seconds = microseconds ~/ Duration.microsecondsPerSecond;
    microseconds = microseconds.remainder(Duration.microsecondsPerSecond);

    var secondsPadding = seconds < 10 ? "0" : "";

    return "$hours:"
        "$minutesPadding$minutes:"
        "$secondsPadding$seconds";
  }

  getHomeData() async {
    // homeLoader.value = true;
    currentPage.value = 1;
    totalPage.value = 1;
    // homeList.clear();
    if (!isFilter.value) {
      await getFilterData();
    }

    try {
      Map<String, dynamic> params = homeDataParams();
      ApiResponseModel<HomeModel> homeModel =
          await DioClient.base().funHomeApi(params);

      if (homeModel.success!) {
        homeList.clear();
        if (homeModel.data != null) {
          homeList.addAll(homeModel.data!.restaurantList!);
          totalPage.value = homeModel.data!.totalPage!;
          currency.value = homeModel.data!.appCurrency!;
          PrefManager.putString(AppConstants.currency, currency.value);
          // var listItems = <PicCluster>[];
          // for (int i = 0; i < homeList.value.length; i++) {
          //   listItems.add(PicCluster(
          //       name: homeList.value[i].restaurantName!,
          //       latLng: LatLng(double.parse(homeList.value[i].latitude.toString()),
          //           double.parse(homeList.value[i].longitude.toString()))));
          // }

          homeList.refresh();
          // manager = _initClusterManager(listItems);
          isPageLoad.value = false;
          homeLoader.value = false;
          isPageLoad.value = false;
          print('cluster_items1: $manager');
        } else {
          isPageLoad.value = false;
          // var listItems = <PicCluster>[];
          // for (int i = 0; i < homeList.value.length; i++) {
          //   listItems.add(PicCluster(
          //       name: 'Test $i}',
          //       latLng: LatLng(double.parse(homeList.value[i].latitude.toString()),
          //           double.parse(homeList.value[i].longitude.toString()))));
          // }
          // markers.clear();
          // homeList.refresh();
          // markers.refresh();
          // manager = _initClusterManager(listItems);
          homeLoader.value = false;
          isPageLoad.value = false;
          // print('cluster_items2: $manager');
          // print('cluster_items2: $markers');
          // print('cluster_items2: $homeList');
        }
      }
      await getUserHomeData();
    } on CustomHttpException catch (exception) {
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
      homeLoader.value = false;
      isPageLoad.value = false;
    } catch (exception) {
      homeLoader.value = false;
      isPageLoad.value = false;
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  getPHomeData() async {
    if (!isFilter.value) {
      await getFilterData();
    }
    try {
      Map<String, dynamic> params = homeDataParams();
      ApiResponseModel<HomeModel> homeModel =
          await DioClient.base().funHomeApi(params);
      if (homeModel.success! && homeModel.data != null) {
        homeList.addAll(homeModel.data!.restaurantList!);
        totalPage.value = homeModel.data!.totalPage!;
        currency.value = homeModel.data!.appCurrency!;

        PrefManager.putString(AppConstants.currency, currency.value);
        // var listItems = <PicCluster>[];
        // for (int i = 0; i < homeList.value.length; i++) {
        //   listItems.add(PicCluster(
        //       name: homeList.value[i].restaurantName!,
        //       latLng: LatLng(double.parse(homeList.value[i].latitude.toString()),
        //           double.parse(homeList.value[i].longitude.toString()))));
        // }

        homeList.refresh();
        // manager = _initClusterManager(listItems);
        isPageLoad.value = false;
        homeLoader.value = false;
        isPageLoad.value = false;
      } else {
        isPageLoad.value = false;
        homeLoader.value = false;
        isPageLoad.value = false;

        // var listItems = <PicCluster>[];
        // for (int i = 0; i < homeList.value.length; i++) {
        //   listItems.add(PicCluster(
        //       name: 'Test $i}',
        //       latLng: LatLng(double.parse(homeList.value[i].latitude.toString()),
        //           double.parse(homeList.value[i].longitude.toString()))));
        // }
        // markers.clear();
        // homeList.refresh();
        // markers.refresh();
        // manager = _initClusterManager(listItems);

        // print('cluster_items2: $manager');
        // print('cluster_items2: $markers');
        // print('cluster_items2: $homeList');
      }
    } on CustomHttpException catch (exception) {
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
      homeLoader.value = false;
      isPageLoad.value = false;
    } catch (exception) {
      homeLoader.value = false;
      isPageLoad.value = false;
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  homeDataParams() {
    var foodTypeIds = getFoodTypeIds();
    var foodPrefIds = getFoodPrefIds();

    Map<String, dynamic> params = {};

    if (lat.value != 0.0 && lng.value != 0.0) {
      params['latitude'] = lat.value;
      params['longitude'] = lng.value;
    }

    params['page'] = currentPage.value;

    if (foodTypeIds.isNotEmpty) {
      params['food_type'] = foodTypeIds;
    }
    if (foodPrefIds.isNotEmpty) {
      params['food_prefrence'] = foodPrefIds;
    }
    if (selectedPickupDay.value != -1) {
      params['day_type'] = pickupDayList[selectedPickupDay.value].toLowerCase();
    }
    if (selectedStockAvailability.value != -1) {
      params['in_stock'] = selectedStockAvailability.value;
    }
    if (selectedPickupDistance.value != 0) {
      params['search_distance'] = selectedPickupDistance.value;
    }

    var pickupStart = DateFormat('HH:mm:ss').format(
        DateTime.fromMicrosecondsSinceEpoch(
            pickupSelectMinTime.toInt() * 1000));
    var pickupEnd = DateFormat('HH:mm:ss').format(
        DateTime.fromMicrosecondsSinceEpoch(
            pickupSelectMaxTime.toInt() * 1000));

    if ((pickupStart != '00:00:00' || pickupEnd != '00:00:00')) {
      if (pickupStart == '00:00:00') {
        params['pickup_start'] = '24:00:00';
      } else {
        params['pickup_start'] = pickupStart;
      }
      if (pickupEnd == '00:00:00') {
        params['pickup_end'] = '24:00:00';
      } else {
        params['pickup_end'] = pickupEnd;
      }
    }
    if (searchText.isNotEmpty) {
      params['key'] = searchText.value;
    }
    if (userId.value != -1) {
      params['user_id'] = userId.value;
    }

    return params;
  }

  getMapData() async {
    // homeLoader.value = true;
    currentPage.value = 1;
    totalPage.value = 1;
    // homeList.clear();
    print("getmapdataapi");
    var foodTypeIds = getFoodTypeIds();
    var foodPrefIds = getFoodPrefIds();
    try {
      Map<String, dynamic> params = {
        'latitude': lat.value,
        'longitude': lng.value,
        'page': currentPage.value
      };
      if (foodTypeIds.isNotEmpty) {
        params['food_type'] = foodTypeIds;
      }
      if (foodPrefIds.isNotEmpty) {
        params['food_prefrence'] = foodPrefIds;
      }
      if (selectedPickupDayMap.value != -1) {
        params['day_type'] =
            pickupDayList[selectedPickupDayMap.value].toLowerCase();
      }
      if (selectedStockAvailabilityMap.value != -1) {
        params['in_stock'] = selectedStockAvailabilityMap.value;
      }
      if (selectedPickupDistance.value != 0) {
        params['search_distance'] = selectedPickupDistance.value;
      }
      var pickupStart = DateFormat('HH:mm:ss').format(
          DateTime.fromMicrosecondsSinceEpoch(
              pickupSelectMinTime.toInt() * 1000));
      var pickupEnd = DateFormat('HH:mm:ss').format(
          DateTime.fromMicrosecondsSinceEpoch(
              pickupSelectMaxTime.toInt() * 1000));

      if ((pickupStart != '00:00:00' || pickupEnd != '00:00:00')) {
        if (pickupStart == '00:00:00') {
          params['pickup_start'] = '24:00:00';
        } else {
          params['pickup_start'] = pickupStart;
        }
        if (pickupEnd == '00:00:00') {
          params['pickup_end'] = '24:00:00';
        } else {
          params['pickup_end'] = pickupEnd;
        }
      }
      if (searchText.isNotEmpty) {
        params['key'] = searchText.value;
      }
      if (userId.value != -1) {
        params['user_id'] = userId.value;
      }
      ApiResponseModel<HomeModel> homeModel =
          await DioClient.base().funHomeApi(params);
      if (homeModel.success! && homeModel.data != null) {
        isPageLoad.value = false;
        homeLoader.value = false;
        mapHomeList.clear();
        mapHomeList.addAll(homeModel.data!.restaurantList!);
        totalPage.value = homeModel.data!.totalPage!;
        currency.value = homeModel.data!.appCurrency!;
        PrefManager.putString(AppConstants.currency, currency.value);
        var listItems = <PicCluster>[];
        for (int i = 0; i < mapHomeList.value.length; i++) {
          listItems.add(PicCluster(
              name: mapHomeList.value[i].restaurantName!,
              latLng: LatLng(
                  double.parse(mapHomeList.value[i].latitude.toString()),
                  double.parse(mapHomeList.value[i].longitude.toString()))));
        }

        mapHomeList.refresh();
        //manager = _initClusterManager(listItems);

        print('cluster_items1: $manager');
      } else {
        markers.clear();

        var listItems = <PicCluster>[];
        for (int i = 0; i < mapHomeList.value.length; i++) {
          listItems.add(PicCluster(
              name: 'Test $i}',
              latLng: LatLng(
                  double.parse(mapHomeList.value[i].latitude.toString()),
                  double.parse(mapHomeList.value[i].longitude.toString()))));
        }

        mapHomeList.refresh();
        markers.refresh();
        //manager = _initClusterManager(listItems);
        isPageLoad.value = false;
        homeLoader.value = false;
        isPageLoad.value = false;
      }
      await getUserHomeData();
    } on CustomHttpException catch (exception) {
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
      homeLoader.value = false;
      isPageLoad.value = false;
    } catch (exception) {
      homeLoader.value = false;
      isPageLoad.value = false;
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  getUserHomeData() async {
    homeLoader.value = true;
    bannerHomeList.clear();
    orderHomeList.clear();
    cartHomeList.clear();
    try {
      var cartId = await PrefManager.getInt(AppConstants.cartId);
      Map<String, dynamic> params = {};
      if (userId.value != -1) {
        params['user_id'] = userId.value;
      }
      if (cartId != 0) {
        params['cart_id'] = cartId;
      }
      ApiResponseModel<UserHomeModel> userHomeModel =
          await DioClient.base().funUserHomeApi(params);
      if (userHomeModel.success! &&
          userHomeModel.data != null &&
          userHomeModel.data!.userHomeDetails != null) {
        if (userHomeModel.data!.userHomeDetails!.orders != null) {
          orderHomeList.addAll(userHomeModel.data!.userHomeDetails!.orders!);
          isOrderInstruction.value = orderHomeList.isNotEmpty;
        }
        if (userHomeModel.data!.userHomeDetails!.banners != null) {
          bannerHomeList.addAll(userHomeModel.data!.userHomeDetails!.banners!);
          // for(int i =0; i<userHomeModel.data!.userHomeDetails!.banners!.length;i++){
          //   userHomeModel.data!.userHomeDetails!.banners![i].videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(""));
          // }
        }

        if (userHomeModel.data!.userHomeDetails!.cartList != null) {
          cartHomeList.add(userHomeModel.data!.userHomeDetails!.cartList!);
        }
        initializeVideo();
        homeLoader.value = false;
        bannerHomeList.refresh();
        cartHomeList.refresh();
        orderHomeList.refresh();
      } else {
        homeLoader.value = false;
      }
    } on CustomHttpException catch (exception) {
      homeLoader.value = false;
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
    } catch (exception) {
      homeLoader.value = false;
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  addFav(index, type) async {
    ProgressDialog progressDialog = ProgressDialog();
    progressDialog.show();
    try {
      var accessToken = await PrefManager.getString(AppConstants.accessToken);
      int? resId = -1;
      if (type == 'fav') {
        resId = favList[index].restaurantId;
      } else if (type == 'map') {
        resId = mapHomeList[index].id;
      } else {
        resId = homeList[index].id;
      }
      Map<String, dynamic> params = {'restro_id': resId};
      ApiResponseModel addFavModel =
          await DioClient.base(accessToken: accessToken).funAddFavApi(params);
      if (addFavModel.success!) {
        if (type == 'home') {
          homeList[index].isLiked = homeList[index].isLiked == "0" ? "1" : "0";
          homeList.refresh();
          progressDialog.dismiss();
        } else if (type == 'map') {
          mapHomeList[index].isLiked =
              mapHomeList[index].isLiked == "0" ? "1" : "0";
          mapHomeList.refresh();
          progressDialog.dismiss();
        } else {
          favList.removeAt(index);
          favList.refresh();
          progressDialog.dismiss();
        }
      } else {
        progressDialog.dismiss();
        errorScreen(error: 'something_went_wrong'.tr);
      }
    } on CustomHttpException catch (exception) {
      progressDialog.dismiss();
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
    } catch (exception) {
      print(exception);
      progressDialog.dismiss();
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  alertBoxRemoveCart() {
    Get.dialog(AlertDialog(
        backgroundColor: ColorsTheme.colWhite,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        content: Wrap(children: [
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Remove Cart",
                  style: boldTextStyle(fontSize: dimen19, color: Colors.black),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "Are you sure you want to remove this item?".tr,
                  textAlign: TextAlign.center,
                  style:
                      regularTextStyle(fontSize: dimen13, color: Colors.black),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: InkWell(
                          onTap: () {
                            Get.back();
                            removeCart(cartHomeList[0].cartId,
                                cartHomeList[0].restroDetail!.restaurantId);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: ColorsTheme.colPrimary,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.black)),
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 30),
                            margin: EdgeInsets.only(left: 5, right: 5),
                            child: Center(
                              child: Text(
                                "Yes".tr,
                                overflow: TextOverflow.ellipsis,
                                style: boldTextStyle(
                                    fontSize: dimen14,
                                    color: ColorsTheme.colWhite),
                              ),
                            ),
                          )),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black)),
                          padding: EdgeInsets.symmetric(
                              vertical: 14, horizontal: 30),
                          margin: EdgeInsets.only(right: 5, left: 5),
                          child: Center(
                            child: Text(
                              "cancel".tr,
                              overflow: TextOverflow.ellipsis,
                              style: boldTextStyle(
                                  fontSize: dimen14, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ])));
  }

  removeCart(int? cartId, int? restaurantId) async {
    ProgressDialog progressDialog = ProgressDialog();
    progressDialog.show();
    try {
      var accessToken = await PrefManager.getString(AppConstants.accessToken);
      Map<String, dynamic> params = {
        'restro_id': restaurantId,
        'cart_id': cartId,
      };
      ApiResponseModel addFavModel =
          await DioClient.base(accessToken: accessToken).removeCartApi(params);
      if (addFavModel.success!) {
        cartHomeList.clear();
        cartHomeList.refresh();
        progressDialog.dismiss();
      } else {
        progressDialog.dismiss();
        errorScreen(error: 'something_went_wrong'.tr);
      }
    } on CustomHttpException catch (exception) {
      progressDialog.dismiss();
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
    } catch (exception) {
      progressDialog.dismiss();
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  getFoodTypeIds() {
    var foodTypeIds = '';
    for (int i = 0; i < foodTypeList.length; i++) {
      if (foodTypeList[i].isSelect!) {
        if (foodTypeIds.isEmpty) {
          foodTypeIds = foodTypeList[i].id.toString();
        } else {
          foodTypeIds = '$foodTypeIds,${foodTypeList[i].id.toString()}';
        }
      }
    }
    return foodTypeIds;
  }

  getFoodPrefIds() {
    var foodPrefIds = '';
    for (int i = 0; i < foodPrefList.length; i++) {
      if (foodPrefList[i].isSelect!) {
        if (foodPrefIds.isEmpty) {
          foodPrefIds = foodPrefList[i].id.toString();
        } else {
          foodPrefIds = '$foodPrefIds,${foodPrefList[i].id.toString()}';
        }
      }
    }
    return foodPrefIds;
  }

  onSelectPickupDay(index) {
    if (selectedPickupDay.value == index) {
      selectedPickupDay.value = -1;
    } else {
      selectedPickupDay.value = index;
    }
    pickupDayList.refresh();
  }

  onSelectPickupDayMap(index) {
    if (selectedPickupDayMap.value == index) {
      selectedPickupDayMap.value = -1;
    } else {
      selectedPickupDayMap.value = index;
    }
    mapPickupDayList.refresh();
  }

  onSelectAvailability(index) {
    if (selectedStockAvailability.value == index) {
      selectedStockAvailability.value = -1;
    } else {
      selectedStockAvailability.value = index;
    }
    pickupStockList.refresh();
  }

  onSelectAvailabilityMap(index) {
    if (selectedStockAvailabilityMap.value == index) {
      selectedStockAvailabilityMap.value = -1;
    } else {
      selectedStockAvailabilityMap.value = index;
    }
    mapPickupStockList.refresh();
  }

  onSelectFoodPref(index) {
    foodPrefList[index].isSelect = !foodPrefList[index].isSelect!;
    foodPrefList.refresh();
  }

  onSelectFoodType(index) {
    foodTypeList[index].isSelect = !foodTypeList[index].isSelect!;
    foodTypeList.refresh();
  }

  clearFilter() async {
    for (int i = 0; i < foodPrefList.length; i++) {
      foodPrefList[i].isSelect = false;
    }
    for (int i = 0; i < foodTypeList.length; i++) {
      foodTypeList[i].isSelect = false;
    }
    selectedPickupDistance.value = 0.0;
    selectedPickupDay.value = -1;
    selectedStockAvailability.value = -1;
    pickupSelectMinTime.value = pickupMinTime.value;
    pickupSelectMaxTime.value = pickupMaxTime.value;
    pickupDayList.refresh();
    pickupStockList.refresh();
    foodPrefList.refresh();
    foodTypeList.refresh();
    isAppliedFilter.value = false;
    homeList.clear();
    homeLoader.value = true;
    await getHomeData();
  }

  clearFilterMap() async {
    for (int i = 0; i < mapFoodPrefList.length; i++) {
      mapFoodPrefList[i].isSelect = false;
    }
    for (int i = 0; i < mapFoodTypeList.length; i++) {
      mapFoodTypeList[i].isSelect = false;
    }
    selectedPickupDistance.value = 0.0;
    selectedPickupDayMap.value = -1;
    selectedStockAvailabilityMap.value = -1;
    pickupSelectMinTime.value = pickupMinTime.value;
    pickupSelectMaxTime.value = pickupMaxTime.value;
    mapPickupDayList.refresh();
    mapPickupStockList.refresh();
    mapFoodPrefList.refresh();
    mapFoodTypeList.refresh();
    isMapAppliedFilter.value = false;
    mapHomeList.clear();
    homeLoader.value = true;
    await getMapData();
  }

  // orders

  getOrdersList() async {
    // orderLoader.value = true;
    // orderCurrentPage.value = 1;
    // orderTotalPage.value = 1;
    // orderList.clear();

    var accessToken = await PrefManager.getString(AppConstants.accessToken);
    try {
      Map<String, dynamic> params = {'page': currentPage.value};
      ApiResponseModel<OrderModel> orderModel =
          await DioClient.base(accessToken: accessToken)
              .funGetOrdersApi(params);

      if (orderModel.success! &&
          orderModel.data != null &&
          orderModel.data!.ordersList != null) {
        orderLoader.value = false;
        isPageLoad.value = false;
        orderList.addAll(orderModel.data!.ordersList!);
        // orderTotalPage.value = orderModel.data!.totalPage!;
        totalPage.value = orderModel.data!.totalPage!;

        totalOrderItem.value = orderModel.data!.totalItem!;
      } else {
        orderLoader.value = false;
        isPageLoad.value = false;
      }
    } on CustomHttpException catch (exception) {
      print("CustomHttpException  in my order api==> ${exception}");
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
      orderLoader.value = false;
      isPageLoad.value = false;
    } catch (exception) {
      print("catch exception in my order api==> ${exception}");
      orderLoader.value = false;
      isPageLoad.value = false;
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  // fav

  getFavData() async {
    // favLoader.value = true;
    // favCurrentPage.value = 1;
    // favTotalPage.value = 1;
    // favList.clear();
    var accessToken = await PrefManager.getString(AppConstants.accessToken);
    try {
      Map<String, dynamic> params = {'page': currentPage.value};
      ApiResponseModel<FavoriteModel> favModel =
          await DioClient.base(accessToken: accessToken).funGetFavApi(params);
      if (favModel.success! && favModel.data != null) {
        favLoader.value = false;
        isPageLoad.value = false;
        favList.addAll(favModel.data!.favouritList!);
        totalPage.value = favModel.data!.totalPage!;
        //favTotalPage.value = favModel.data!.totalPage!;
      } else {
        favLoader.value = false;
        isPageLoad.value = false;
      }
    } on CustomHttpException catch (exception) {
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
      favLoader.value = false;
      isPageLoad.value = false;
    } catch (exception) {
      favLoader.value = false;
      isPageLoad.value = false;
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  // me

  getMyProfile() async {
    var progressDialog = ProgressDialog();
    progressDialog.show();
    var accessToken = await PrefManager.getString(AppConstants.accessToken);
    print("accessToken $accessToken");
    try {
      ApiResponseModel<UserModel> userModel =
          await DioClient.base(accessToken: accessToken).funGetMyProfileApi();
      if (userModel.success! &&
          userModel.data != null &&
          userModel.data!.user != null) {
        progressDialog.dismiss();

        PrefManager.putString(
            AppConstants.userProfile, json.encode(userModel.data!.user!));
        getUpdatedUserData();
        await getEarning();
      } else {
        progressDialog.dismiss();
        await getEarning();
      }
    } on CustomHttpException catch (exception) {
      progressDialog.dismiss();
      await getEarning();
    } catch (e) {
      progressDialog.dismiss();
      await getEarning();
    }
  }

  getEarning() async {
    var accessToken = await PrefManager.getString(AppConstants.accessToken);
    print("accessTokenmoney $accessToken");

    try {
      ApiResponseModel<EarningModel> earningModel =
          await DioClient.multipartBase(accessToken: accessToken)
              .funGetEarning();
      print("earningModel${earningModel.success}");
      if (earningModel.success! && earningModel.data != null) {
        // totalValue.value = double.parse(earningModel.data!.earning!.money!.savedMoney!.toString());
        // magicalBag.value = earningModel.data!.earning!.money!.bag!;
        // originalValue.value = double.parse(earningModel.data!.earning!.money!.orignalValue!.toString());
        // youPaidValue.value = double.parse(earningModel.data!.earning!.money!.totalPaid!.toString());

        print(
            "moneysaved ${earningModel.data!.earning!.money!.savedMoney!.toString()}");

        moneySaved.value = double.parse(
            earningModel.data!.earning!.money!.savedMoney!.toString());
        money.value = NumberFormat.compact().format(moneySaved.value);

        print("moneyvalye ${money.value}");
        var totalCo2 =
            double.parse(earningModel.data!.earning!.co2!.savedCo2!.toString());
        // co2Saved.value = currentUser.co2!;
        if (totalCo2 < 100) {
          co2Saved.value = "${totalCo2.toStringAsFixed(3)} kg";
        } else if (totalCo2 >= 100 && totalCo2 < 1000) {
          var quental = totalCo2 / 100;
          co2Saved.value = "${quental.toStringAsFixed(3)} Q";
        } else {
          var ton = totalCo2 / 1000;
          co2Saved.value = "${ton.toStringAsFixed(3)} Q";
        }
      } else {}
    } on CustomHttpException catch (exception) {
      print("exception $exception");
    } catch (e) {
      print("exception $e");
    }
  }

  logOut() async {
    if (!isLogOut.value) {
      isLogOut.value = true;
      await logoutApi();
      PrefManager.remove(AppConstants.deviceId);
      PrefManager.remove(AppConstants.userProfile);
      PrefManager.remove(AppConstants.userId);
      PrefManager.remove(AppConstants.accessToken);
      PrefManager.putBool(AppConstants.loggedIn, false);
      PrefManager.remove(AppConstants.cartId);
      Get.offAllNamed(Routes.intro);
    }
  }

  logoutApi() async {
    try {
      Map<String, dynamic> params = {
        'user_id': userId.value,
      };
      await DioClient.base().funLogoutAccountApi(params);
    } on CustomHttpException catch (exception) {
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
    } catch (exception) {
      print("exception ${exception}");
    }
  }

  onMoneyTap({title, flag, totalValue, unit}) {
    if (isLoggedIn.value) {
      Get.toNamed(Routes.moneyCo2Saved, arguments: {
        'title': title,
        'screenFlag': flag,
        'totalValue': totalValue,
        'unit': unit
      });
    } else {
      loginBottomSheet();
    }
  }

  loginBottomSheet() {
    return Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
            color: ColorsTheme.colWhite,
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Wrap(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Log in'.tr,
                    style: boldTextStyle(
                        fontSize: dimen15, color: ColorsTheme.colBlack),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: Text(
                    'login_subtitle'.tr,
                    style: regularTextStyle(
                        fontSize: dimen12, color: ColorsTheme.colBlack),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.offAllNamed(Routes.intro, arguments: false);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 15),
                    decoration: BoxDecoration(
                        color: ColorsTheme.colPrimary,
                        borderRadius: BorderRadius.circular(40)),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    alignment: Alignment.center,
                    child: Text(
                      '${'Log in'.tr} →',
                      style: semiBoldTextStyle(
                          fontSize: dimen13, color: ColorsTheme.colWhite),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  buildProgressIndicator() {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Opacity(
              opacity: isPageLoad.value ? 1.0 : 0.0,
              child: CircularProgressIndicator(
                color: ColorsTheme.colPrimary,
              ),
            ),
          ),
        ));
  }

  filterBottomSheet(context) {
    return Get.bottomSheet(StatefulBuilder(builder: (context, setState) {
      return Wrap(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
                color: ColorsTheme.colWhite),
            width: Get.width,
            height: Get.height / 1.2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  child: Text(
                    'Filters'.tr,
                    style: semiBoldTextStyle(
                        fontSize: dimen17, color: ColorsTheme.colBlack),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => foodTypeList.isEmpty
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 20, left: 20, right: 20),
                                    child: Text(
                                      'Food Type'.tr,
                                      style: mediumTextStyle(
                                          fontSize: dimen13,
                                          color: ColorsTheme.colBlack),
                                    ),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          top: 10, left: 10, right: 10),
                                      child: foodTypeChipList()),
                                ],
                              )),
                        Obx(() => foodPrefList.isEmpty
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, left: 20, right: 20),
                                    child: Text(
                                      'Food Preferences'.tr,
                                      style: mediumTextStyle(
                                          fontSize: dimen13,
                                          color: ColorsTheme.colBlack),
                                    ),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          top: 10, left: 10, right: 10),
                                      child: foodPrefChipList()),
                                ],
                              )),
                        Obx(() => pickupDistanceMax.value == 0
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, left: 20, right: 20),
                                    child: Text(
                                      'Pickup Distance'.tr,
                                      style: mediumTextStyle(
                                          fontSize: dimen13,
                                          color: ColorsTheme.colBlack),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, left: 20, right: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'O Km',
                                          style: regularTextStyle(
                                              fontSize: dimen11,
                                              color: ColorsTheme.colBlack),
                                        ),
                                        Text(
                                          '${selectedPickupDistance.value}',
                                          style: regularTextStyle(
                                              fontSize: dimen11,
                                              color: ColorsTheme.colBlack),
                                        ),
                                        Text(
                                          '${pickupDistanceMax.value} Km',
                                          style: regularTextStyle(
                                              fontSize: dimen11,
                                              color: ColorsTheme.colBlack),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          top: 10, left: 10, right: 10),
                                      child: Obx(
                                        () => SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                              thumbShape:
                                                  const RoundSliderThumbShape(),
                                              activeTrackColor:
                                                  ColorsTheme.colPrimary,
                                              inactiveTrackColor:
                                                  ColorsTheme.col8FA19C,
                                              overlayShape:
                                                  const RoundSliderOverlayShape(
                                                      overlayRadius: 1),
                                              trackHeight: 3),
                                          child: Slider(
                                            value: selectedPickupDistance.value,
                                            min: 0,
                                            max: pickupDistanceMax.value,
                                            divisions:
                                                pickupDistanceMax.value.toInt(),
                                            onChanged: (double value) {
                                              selectedPickupDistance.value =
                                                  value;
                                            },
                                          ),
                                        ),
                                      )),
                                ],
                              )),
                        Obx(() => pickupDayList.isEmpty
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, left: 20, right: 20),
                                    child: Text(
                                      'Pick-up Day'.tr,
                                      style: mediumTextStyle(
                                          fontSize: dimen13,
                                          color: ColorsTheme.colBlack),
                                    ),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          top: 10, left: 10, right: 10),
                                      child: pickupDayChipList()),
                                ],
                              )),
                        Obx(() => pickupStockList.isEmpty
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, left: 20, right: 20),
                                    child: Text(
                                      'Availability'.tr,
                                      style: mediumTextStyle(
                                          fontSize: dimen13,
                                          color: ColorsTheme.colBlack),
                                    ),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          top: 10, left: 10, right: 10),
                                      child: pickupStockChipList()),
                                ],
                              )),
                        Obx(() => isPickupHoursList.value
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, left: 20, right: 20),
                                    child: Text(
                                      'Pick-up window'.tr,
                                      style: mediumTextStyle(
                                          fontSize: dimen13,
                                          color: ColorsTheme.colBlack),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, left: 20, right: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat('hh:mm a').format(DateTime
                                              .fromMicrosecondsSinceEpoch(
                                                  pickupSelectMinTime.toInt() *
                                                      1000)),
                                          style: regularTextStyle(
                                              fontSize: dimen11,
                                              color: ColorsTheme.colBlack),
                                        ),
                                        Text(
                                          DateFormat('hh:mm a').format(DateTime
                                              .fromMicrosecondsSinceEpoch(
                                                  pickupSelectMaxTime.toInt() *
                                                      1000)),
                                          style: regularTextStyle(
                                              fontSize: dimen11,
                                              color: ColorsTheme.colBlack),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          top: 10, left: 20, right: 20),
                                      child: Obx(
                                        () => SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                              thumbShape:
                                                  const RoundSliderThumbShape(),
                                              activeTrackColor:
                                                  ColorsTheme.colPrimary,
                                              inactiveTrackColor:
                                                  ColorsTheme.col8FA19C,
                                              disabledActiveTickMarkColor:
                                                  Colors.transparent,
                                              disabledInactiveTickMarkColor:
                                                  Colors.transparent,
                                              activeTickMarkColor:
                                                  Colors.transparent,
                                              inactiveTickMarkColor:
                                                  Colors.transparent,
                                              overlayShape:
                                                  const RoundSliderOverlayShape(
                                                      overlayRadius: 1),
                                              trackHeight: 3),
                                          child: RangeSlider(
                                            values: RangeValues(
                                                pickupSelectMinTime.value,
                                                pickupSelectMaxTime.value),
                                            min: pickupMinTime.value,
                                            max: pickupMaxTime.value,
                                            divisions: 48,
                                            onChanged: (RangeValues value) {
                                              pickupSelectMinTime.value =
                                                  value.start.toPrecision(0);
                                              pickupSelectMaxTime.value =
                                                  value.end.toPrecision(0);
                                              print(pickupSelectMinTime.value
                                                  .toString());
                                              //print(controller.pickupSelectMaxTime.value.toString());
                                            },
                                          ),
                                        ),
                                      )),
                                ],
                              )
                            : Container()),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    clearFilterMap();
                                    Get.back();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: ColorsTheme.colBlack,
                                            width: 1),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      'Clear All'.tr,
                                      style: semiBoldTextStyle(
                                          fontSize: dimen13,
                                          color: ColorsTheme.colBlack),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    Get.back();
                                    isMapAppliedFilter.value = true;
                                    currentPage.value = 1;
                                    mapHomeList.clear();
                                    markers.clear();
                                    homeLoader.value = true;

                                    mapHomeList.refresh();
                                    markers.refresh();
                                    await getAddress();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: ColorsTheme.colPrimary,
                                        border: Border.all(
                                            color: Colors.transparent,
                                            width: 1),
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      'Apply'.tr,
                                      style: semiBoldTextStyle(
                                          fontSize: dimen13,
                                          color: ColorsTheme.colWhite),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }), isScrollControlled: true);
  }

  Widget foodTypeChipList() {
    return Wrap(
      spacing: 0,
      children: List.generate(
        mapFoodTypeList.length,
        (index) {
          return GestureDetector(
            onTap: () {
              onSelectFoodType(index);
            },
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Obx(() => labelChip(
                    label: mapFoodTypeList[index].name!,
                    isSelect: mapFoodTypeList[index].isSelect!))),
          );
        },
      ),
    );
  }

  Widget labelChip({
    String? label,
    bool? isSelect,
  }) {
    return Container(
      decoration: isSelect!
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: ColorsTheme.colPrimary,
              border: Border.all(width: 1, color: Colors.transparent))
          : BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.transparent,
              border: Border.all(width: 1, color: ColorsTheme.colBlack)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label!,
        style: regularTextStyle(
          fontSize: dimen11,
          color: isSelect ? ColorsTheme.colWhite : ColorsTheme.colBlack,
        ),
      ),
    );
  }

  Widget foodPrefChipList() {
    return Wrap(
      spacing: 10,
      children: List.generate(
        mapFoodPrefList.length,
        (index) {
          return GestureDetector(
            onTap: () {
              onSelectFoodPref(index);
            },
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Obx(
                  () => imageLabelChip(
                    label: mapFoodPrefList[index].name!,
                    isSelect: mapFoodPrefList[index].isSelect!,
                    image: mapFoodPrefList[index].image!,
                  ),
                )),
          );
        },
      ),
    );
  }

  Widget imageLabelChip({String? label, bool? isSelect, String? image}) {
    return Container(
      decoration: isSelect!
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: ColorsTheme.colPrimary,
              border: Border.all(width: 1, color: Colors.transparent))
          : BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.transparent,
              border: Border.all(width: 1, color: ColorsTheme.colBlack)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Image.network(image!, width: 20, height: 20,
                errorBuilder: (context, obj, stack) {
              return Image.asset(
                Res.icDummyFoodType,
                width: 20,
                height: 20,
              );
            }),
          ),
          Text(
            label!,
            style: regularTextStyle(
              fontSize: dimen11,
              color: isSelect ? ColorsTheme.colWhite : ColorsTheme.colBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget pickupDayChipList() {
    return Wrap(
      spacing: 10,
      children: List.generate(
        mapPickupDayList.length,
        (index) {
          return GestureDetector(
            onTap: () {
              onSelectPickupDayMap(index);
            },
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Obx(
                  () => labelChip(
                      label: mapPickupDayList[index],
                      isSelect: selectedPickupDayMap.value == index),
                )),
          );
        },
      ),
    );
  }

  Widget pickupStockChipList() {
    return Wrap(
      spacing: 10,
      children: List.generate(
        mapPickupStockList.length,
        (index) {
          return GestureDetector(
            onTap: () {
              onSelectAvailabilityMap(index);
              print("onSelectAvailability $index");
            },
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Obx(
                  () => labelChip(
                      label: mapPickupStockList[index],
                      isSelect: selectedStockAvailabilityMap.value == index),
                )),
          );
        },
      ),
    );
  }
}

class PicCluster with ClusterItem {
  final String name;
  final bool isClosed;
  final LatLng latLng;

  PicCluster({required this.name, required this.latLng, this.isClosed = false});

  @override
  String toString() {
    return 'Place $name (closed : $isClosed)';
  }

  @override
  LatLng get location => latLng;
}
