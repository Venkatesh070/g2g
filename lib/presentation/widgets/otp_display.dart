import 'package:flutter/material.dart';
import 'package:good_grab/infrastructure/theme/colors.theme.dart';
import 'package:good_grab/infrastructure/theme/text.theme.dart';

class OtpDisplay extends StatelessWidget {
  final String otp;
  final double boxSize;
  final double spacing;
  final BorderRadius borderRadius;

  const OtpDisplay({
    super.key,
    required this.otp,
    this.boxSize = 20,
    this.spacing = 3,
    this.borderRadius = const BorderRadius.all(Radius.circular(5)),
  }) : assert(otp.length == 4, 'OTP must be exactly 4 characters');

  @override
  Widget build(BuildContext context) {
    final characters = otp.split('');
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: spacing,
      runSpacing: 0,
      children: List.generate(4, (index) {
        return Container(
          width: boxSize,
          height: boxSize,
          decoration: BoxDecoration(
            color: ColorsTheme.colWhite.withOpacity(0.5),
            borderRadius: borderRadius,
            border: Border.all(color: ColorsTheme.colPrimary, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            characters[index],
            style: semiBoldTextStyle(
              fontSize: boxSize * 0.52,
              color: ColorsTheme.colBlack,
            ),
          ),
        );
      }),
    );
  }
}


