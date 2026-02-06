import 'package:flutter/animation.dart';
import 'package:get/get.dart';

import 'package:good_grab/presentation/allow_permission/allow_permission_binding.dart';
import 'package:good_grab/presentation/allow_permission/allow_permission_page.dart';
import 'package:good_grab/presentation/app_content/app_content_binding.dart';
import 'package:good_grab/presentation/app_content/app_content_page.dart';
import 'package:good_grab/presentation/cart/cart_binding.dart';
import 'package:good_grab/presentation/cart/cart_page.dart';
import 'package:good_grab/presentation/change_number_email/change_number_email_binding.dart';
import 'package:good_grab/presentation/change_number_email/change_number_email_page.dart';
import 'package:good_grab/presentation/custom_camera/custom_camera_binding.dart';
import 'package:good_grab/presentation/custom_camera/custom_camera_page.dart';
import 'package:good_grab/presentation/edit_profile/edit_profile_binding.dart';
import 'package:good_grab/presentation/edit_profile/edit_profile_page.dart';
import 'package:good_grab/presentation/home-details/home_details_binding.dart';
import 'package:good_grab/presentation/home-details/home_details_page.dart';
import 'package:good_grab/presentation/home/home_binding.dart';
import 'package:good_grab/presentation/home/home_page.dart';
import 'package:good_grab/presentation/image_detail/image_detail_binding.dart';
import 'package:good_grab/presentation/image_detail/image_detail_view.dart';
import 'package:good_grab/presentation/intro/intro_binding.dart';
import 'package:good_grab/presentation/intro/intro_page.dart';
import 'package:good_grab/presentation/login/login_binding.dart';
import 'package:good_grab/presentation/login/login_page.dart';
import 'package:good_grab/presentation/money_co2_saved/money_co2_saved_binding.dart';
import 'package:good_grab/presentation/money_co2_saved/money_co2_saved_page.dart';
import 'package:good_grab/presentation/notification/notification_binding.dart';
import 'package:good_grab/presentation/notification/notification_page.dart';
import 'package:good_grab/presentation/order_cancel/order_cancel_binding.dart';
import 'package:good_grab/presentation/order_cancel/order_cancel_page.dart';
import 'package:good_grab/presentation/otp_verify/otp_verify_binding.dart';
import 'package:good_grab/presentation/otp_verify/otp_verify_page.dart';
import 'package:good_grab/presentation/payment_status/payment_status_binding.dart';
import 'package:good_grab/presentation/payment_status/payment_status_page.dart';
import 'package:good_grab/presentation/search_location/search_location_binding.dart';
import 'package:good_grab/presentation/search_location/search_location_page.dart';
import 'package:good_grab/presentation/splash/splash_binding.dart';
import 'package:good_grab/presentation/splash/splash_page.dart';


import '../../presentation/app_setting/app_setting_binding.dart';
import '../../presentation/app_setting/app_setting_page.dart';
import '../../presentation/order_details/order_details_binding.dart';
import '../../presentation/order_details/order_details_page.dart';
import '../../presentation/order_status/order_status_binding.dart';
import '../../presentation/order_status/order_status_page.dart';
import '../../presentation/order_picked/order_picked_binding.dart';
import '../../presentation/order_picked/order_picked_page.dart';
import 'routes.dart';

class AppPages {
  static List<GetPage> pageList = [
    GetPage(
      name: Routes.splash,
      page: () => SplashPage(),
      binding: SplashBinding(),
  transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 500)
    ),
    GetPage(
      name: Routes.intro,
      page: () => IntroPage(),
      binding: IntroBinding(),
        transition: Transition.downToUp,
      curve: Curves.fastOutSlowIn,
      transitionDuration: const Duration(seconds: 1)
    ),
    GetPage(
        name: Routes.login,
        page: () => LoginPage(),
        binding: LoginBinding(),
        transition: Transition.downToUp,
        curve: Curves.fastOutSlowIn,
        transitionDuration: const Duration(milliseconds: 800)
    ),
    GetPage(
      name: Routes.otpVerify,
      page: () => OtpVerifyPage(),
      binding: OtpVerifyBinding(),
    ),
    GetPage(
      name: Routes.allowPermission,
      page: () => AllowPermissionPage(),
      binding: AllowPermissionBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.searchLocation,
      page: () => SearchLocationPage(),
      binding:  SearchLocationBinding(),
    ),
    GetPage(
      name: Routes.homeDetails,
      page: () => HomeDetailsPage(),
      binding:  HomeDetailsBinding(),
    ),
    GetPage(
      name: Routes.appContents,
      page: () => AppContentPage(),
      binding:  AppContentBinding(),
        transition: Transition.downToUp,
        curve: Curves.fastOutSlowIn,
        transitionDuration: const Duration(milliseconds: 500)
    ),
    GetPage(
        name: Routes.editProfile,
        page: () => EditProfilePage(),
        binding:  EditProfileBinding(),
        transition: Transition.downToUp,
        curve: Curves.fastOutSlowIn,
        transitionDuration: const Duration(milliseconds: 500)
    ),
    GetPage(
        name: Routes.customCamera,
        page: () =>  const CustomCameraPage(),
        binding: CustomCameraBinding(),
        transition: Transition.downToUp,
        curve: Curves.fastOutSlowIn,
        transitionDuration: const Duration(milliseconds: 500)
    ),
    GetPage(
        name: Routes.changeNumber,
        page: () =>   ChangeNumberEmailPage(),
        binding: ChangeNumberEmailBinding(),
        transition: Transition.downToUp,
        curve: Curves.fastOutSlowIn,
        transitionDuration: const Duration(milliseconds: 500)
    ),
    GetPage(
        name: Routes.moneyCo2Saved,
        page: () =>   MoneyCO2SavedPage(),
        binding: MoneyCO2SavedBinding(),
        transition: Transition.downToUp,
        curve: Curves.fastOutSlowIn,
        transitionDuration: const Duration(milliseconds: 500)
    ),
    GetPage(
        name: Routes.orderDetails,
        page: () =>  OrderDetailsPage(),
        binding:  OrderDetailsBinding(),
        transition: Transition.downToUp,
        curve: Curves.fastOutSlowIn,
        transitionDuration: const Duration(milliseconds: 500)
    ),
    GetPage(
        name: Routes.orderStatus,
        page: () =>  OrderStatusPage(),
        binding:  OrderStatusBinding(),
        transition: Transition.downToUp,
        curve: Curves.fastOutSlowIn,
        transitionDuration: const Duration(milliseconds: 500)
    ),
    GetPage(
        name: Routes.orderCancel,
        page: () =>  OrderCancelPage(),
        binding:  OrderCancelBinding(),
        transition: Transition.downToUp,
        curve: Curves.fastOutSlowIn,
        transitionDuration: const Duration(milliseconds: 500)
    ),

    GetPage(
        name: Routes.notification,
        page: () =>  NotificationPage(),
        binding:  NotificationBinding(),
        transition: Transition.downToUp,
        curve: Curves.fastOutSlowIn,
        transitionDuration: const Duration(milliseconds: 500)
    ),

    GetPage(
        name: Routes.cart,
        page: () =>  CartPage(),
        binding:  CartBinding(),
        transition: Transition.downToUp,
        /*curve: Curves.fastOutSlowIn,
        transitionDuration: const Duration(milliseconds: 500)*/
    ),

    GetPage(
        name: Routes.appSettings,
        page: () =>  AppSettingPage(),
        binding:  AppSettingBinding(),
        transition: Transition.downToUp,
        curve: Curves.fastOutSlowIn,
        transitionDuration: const Duration(milliseconds: 500)
    ),

    GetPage(
        name: Routes.paymentStatus,
        page: () =>  PaymentStatusPage(),
        binding:  PaymentStatusBinding(),
        transition: Transition.downToUp,
        curve: Curves.fastOutSlowIn,
        transitionDuration: const Duration(milliseconds: 500)
    ),
    GetPage(
        name: Routes.imageDetail,
        page: () =>  ImageDetailPage(),
        binding:  ImageDetailBinding(),
        transition: Transition.downToUp,
        curve: Curves.fastOutSlowIn,
        transitionDuration: const Duration(milliseconds: 500)
    ),
    GetPage(
        name: Routes.orderPicked,
        page: () =>  OrderPickedPage(),
        binding: OrderPickedBinding(),
        transition: Transition.downToUp,
        curve: Curves.fastOutSlowIn,
        transitionDuration: const Duration(milliseconds: 500)
    ),

  ];
}
