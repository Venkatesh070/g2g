import 'package:get/get.dart';
import 'package:good_grab/presentation/change_number_email/change_number_email_controller.dart';

class ChangeNumberEmailBinding extends Bindings{

  @override
  void dependencies() {
    Get.lazyPut(() => ChangeNumberEmailController());
  }

}