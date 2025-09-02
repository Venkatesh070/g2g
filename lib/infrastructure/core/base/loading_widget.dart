
import 'package:flutter/material.dart';


class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Stack(
        children: <Widget>[
          ModalBarrier(
            dismissible: false,
            color: Colors.grey.withOpacity(.3),
          ),
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
