import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_grab/presentation/custom_camera/custom_camera_controller.dart';

import '../../res.dart';

class CustomCameraPage extends GetView<CustomCameraController>{
  const CustomCameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
            () => controller.isFirst.value?
        Container(
          height: Get.height,
          color: Colors.white,
          child:  const Center(child: CircularProgressIndicator()),
        )
            : controller.imagePath.value.isNotEmpty
            ?Stack(
          children: [
            Container(
                color: Colors.red,
                height: Get.height,
                child: Image.file(
                  File(controller.imagePath.value),
                  fit: BoxFit.fill,
                )),
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.only(left: 10,right: 10),
                  height: MediaQuery.of(context).size.height/6,
                  width: 90,
                  decoration: const BoxDecoration(
                      color: Colors.black
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: (){
                          Get.back();
                        },
                        child: Image.asset(Res.icImageCancel,
                          height: 40,
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          Get.back(result: [controller.imagePath.value]);
                        },
                        child:   Image.asset(Res.icImageDone,
                          height: 40,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          controller.imagePath.value = "";
                        },
                        child:  Image.asset(Res.icImageFlip,
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ))
          ],
        )
            : Stack(
          fit: StackFit.expand,
          children: [
            SizedBox(
              width: Get.width,
              height: Get.height,child: FutureBuilder(
              future: controller.initializeControllerFuture,
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if(snapshot.connectionState == ConnectionState.done){
                  return Transform.scale(
                    scale:   1.0,
                    child: AspectRatio(
                        aspectRatio: 1 / controller.cameraController.value.aspectRatio,
                        child: CameraPreview(controller.cameraController)),
                  );
                }
                else{
                  return  SizedBox(
                    height: Get.height,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
              },

            ),),
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height/6,

                  decoration:  BoxDecoration(
                      color: Colors.black.withOpacity(0.4)
                  ),
                  padding: const EdgeInsets.only(left: 15,right: 15),
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () {
                      controller.onTapClickImage();
                    },

                    child: Image.asset(Res.icImageCapture,
                      height: 80,
                    ),

                  ),
                )),
            Positioned(
                left: 30,
                bottom: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height/6,
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: (){
                      Get.back();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: Image.asset(Res.icImageCancel,
                        height: 35,
                      ),
                    ),
                  ),
                )),
            Positioned.fill(
              bottom: 3,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: (){
                    Get.back();
                  },
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    color: Colors.white,
                    height: 1.2,
                    width: 72,
                  ),
                ),
              ),
            ),
            Positioned(
                right: 30,
                bottom: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height/6,
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: (){
                      controller.toggleCamera();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: Image.asset(Res.icImageCancel,
                        height: 35,
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

}
