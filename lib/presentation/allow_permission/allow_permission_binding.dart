import 'package:get/get.dart';

import 'allow_permission_controller.dart';

class AllowPermissionBinding extends Bindings{

  @override
  void dependencies() {
    Get.lazyPut(() => AllowPermissionController());
  }

}