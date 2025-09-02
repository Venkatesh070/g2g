import 'package:get/get.dart';
import 'package:good_grab/presentation/home-details/home_details_controller.dart';

class HomeDetailsBinding extends Bindings{

  @override
  void dependencies() {
    Get.lazyPut(() => HomeDetailsController());
  }

}