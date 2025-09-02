import 'package:camera/camera.dart';
import 'package:get/get.dart';

class CustomCameraController extends GetxController{

  List<CameraDescription> cameras = [];
  late CameraController cameraController;
  late Future<void> initializeControllerFuture;
  var isFlashOn = false.obs;
  var imagePath = "".obs;
  var isFirst = true.obs;
  var screenType = '';
  var isFrontCamera = true.obs;


  @override
  void onInit() {
    cameras = Get.arguments;

    Future.delayed(const Duration(milliseconds: 100),() async {

      await initializeCamera();
      isFirst.value = false;
    }) ;
    super.onInit();
  }


  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> initializeCamera() async {
    final selectedCamera = isFrontCamera.value ? cameras[1] : cameras[0]; // Switch between front and rear cameras
    cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.veryHigh,
    );
    initializeControllerFuture = cameraController.initialize();
  }

  onTapClickImage() async {
    isFirst.value = true;
    try {
      final XFile image = await cameraController.takePicture();
      imagePath.value = image.path;
      Future.delayed(const Duration(milliseconds: 100),(){
        isFirst.value = false;
      }) ;

      // Use the captured image
      print('Image captured: ${image.path}');
    } catch (e) {
      isFirst.value = false;
      print('Error capturing image: $e');
    }
  }

  onTapFlashOn() {
    isFlashOn.value = true;
    cameraController.setFlashMode(FlashMode.torch);
  }

  onTapFlashOff() {
    isFlashOn.value = false;
    cameraController.setFlashMode(FlashMode.off);
  }

  toggleCamera() {
    isFrontCamera.value = !isFrontCamera.value;
    initializeCamera();
  }
}
