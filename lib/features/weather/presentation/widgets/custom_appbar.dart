import 'package:flutter/material.dart';
import 'package:weather_app/features/weather/presentation/widgets/header_text.dart';

/// A customizable transparent app bar for the weather app.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final double elevation;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.elevation = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? HeaderText(
              text: title!,
              fontSize: 20.0,
              textAlign: TextAlign.center,
            )
          : null,
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: elevation,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
