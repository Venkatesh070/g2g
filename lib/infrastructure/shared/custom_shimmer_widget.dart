import 'package:flutter/material.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmerWidget extends StatelessWidget {

  final double width;
  final double height;
  final double? borderRadius;
  final ShapeBorder shapeBorder;

  const CustomShimmerWidget.rectangular({
    super.key,
    this.width = double.infinity,
    this.borderRadius,
    required this.height
  }): shapeBorder = borderRadius == null ? const RoundedRectangleBorder():const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(5))
  );

  const CustomShimmerWidget.circular({super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius,
    this.shapeBorder = const CircleBorder()
  });

  @override
  Widget build(BuildContext context)  => Shimmer.fromColors(
    baseColor: ColorsTheme.colBackground,
    highlightColor: Colors.grey[300]!,
    period: const Duration(seconds: 2),
    
    child: Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: Colors.grey[400]!,
        shape: shapeBorder,

      ),
    ),
  );
}