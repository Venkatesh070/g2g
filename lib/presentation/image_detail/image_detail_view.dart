
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:good_grab/infrastructure/core/base/base_view.dart';
import 'package:get/get.dart';
import 'image_detail_controller.dart';

class ImageDetailPage  extends BaseView<ImageDetailController>{
  ImageDetailPage({super.key});

  @override
  Widget body(BuildContext context) {
    // TODO: implement body

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
       automaticallyImplyLeading: false,
        centerTitle: false,
        title: InkWell(
            onTap: (){
              Get.back();
            },
            child: const Icon(Icons.arrow_back_outlined,color: Colors.black,)),
      ),
      body: Center(
        child: Image.network(controller.image.value),
      ),
    );
  }

}