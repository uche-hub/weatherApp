import 'package:flutter/material.dart';
import 'package:weather_app/core/constants/app_color.dart';

/// A clean and elegant circular loader for screen or widget loading states.
class CircularLoader extends StatelessWidget {
  final double size;
  final double strokeWidth;

  const CircularLoader({super.key, this.size = 48.0, this.strokeWidth = 4.0});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryBlue),
          backgroundColor: AppColor.secondaryTextLight.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
