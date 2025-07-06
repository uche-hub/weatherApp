import 'package:flutter/material.dart';
import 'package:weather_app/core/constants/app_color.dart';

/// A horizontal loader widget for button loading states.
class HorizontalLoader extends StatelessWidget {
  final double height;
  final double width;

  const HorizontalLoader({
    super.key,
    this.height = 4.0,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryBlue),
      backgroundColor: AppColor.secondaryTextLight.withValues(alpha: 0.3),
      minHeight: height,
    );
  }
}