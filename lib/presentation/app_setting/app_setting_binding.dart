import 'package:get/get.dart';
import 'package:good_grab/presentation/app_setting/app_setting_controller.dart';

class AppSettingBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => AppSettingController());
  }

}