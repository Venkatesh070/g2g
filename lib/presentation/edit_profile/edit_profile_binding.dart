import 'package:get/get.dart';
import 'package:good_grab/presentation/edit_profile/edit_profile_controller.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EditProfileController());
  }
}
