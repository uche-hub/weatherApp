import 'package:flutter/material.dart';
import 'package:weather_app/core/constants/app_color.dart';
import 'package:weather_app/features/weather/presentation/widgets/description_text.dart';

enum ToastType { success, failure }

class CustomToast {
  /// Shows a toast message with an icon based on the toast type.
  static void show({
    required BuildContext context,
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            type == ToastType.success ? Icons.check_circle : Icons.error,
            color: type == ToastType.success
                ? AppColor.successGreen
                : AppColor.errorRed,
            size: 24.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: DescriptionText(text: message, fontSize: 14.0, maxLines: 2),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).cardColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      duration: duration,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
