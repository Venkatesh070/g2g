import 'package:get/get.dart';
import 'package:good_grab/presentation/search_location/search_location_controller.dart';

class SearchLocationBinding extends Bindings{

  @override
  void dependencies() {
    Get.lazyPut(() => SearchLocationController());
  }

}