import 'package:get/get.dart';
import 'package:good_grab/presentation/custom_camera/custom_camera_controller.dart';

class CustomCameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CustomCameraController());
  }
}
