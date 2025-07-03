import 'package:flutter/material.dart';
import 'package:weather_app/core/constants/app_color.dart';
import 'package:weather_app/core/constants/routes/routes.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: AppColor.lightTheme,
      darkTheme: AppColor.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}