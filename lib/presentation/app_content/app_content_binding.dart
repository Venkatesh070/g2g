import 'package:get/get.dart';

import 'app_content_controller.dart';

class AppContentBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => AppContentController());
  }

}