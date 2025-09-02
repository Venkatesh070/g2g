import 'package:get/get.dart';
import 'package:good_grab/presentation/money_co2_saved/money_co2_saved_controller.dart';

class MoneyCO2SavedBinding extends Bindings{

  @override
  void dependencies() {
    Get.lazyPut(() => MoneyCO2SavedController());
  }

}