import 'package:get/get.dart';

class ImageDetailController extends GetxController{
var image = "".obs;

  @override
  void onInit() {
  image.value = Get.arguments[0];

    super.onInit();
  }
}