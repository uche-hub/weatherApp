import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather_app/core/constants/app_color.dart';
import 'package:weather_app/core/constants/routes/routes.dart';
import 'package:weather_app/features/weather/data/models/city_weather.dart';
import 'package:weather_app/features/weather/data/repos/weather_repo.dart';
import 'package:weather_app/features/weather/presentation/bloc/weather_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CityWeatherAdapter());
  await Hive.openBox<CityWeather>('weather_cities');

  final weatherRepository = WeatherRepository();

  runApp(MyApp(weatherRepository: weatherRepository));

  runApp(MyApp(weatherRepository: weatherRepository));
}

class MyApp extends StatelessWidget {
  final WeatherRepository weatherRepository;

  const MyApp({super.key, required this.weatherRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          WeatherBloc(weatherRepository)..add(LoadWeather()), //  Start the bloc + trigger load ONCE
      child: MaterialApp.router(
        title: 'Weather App',
        theme: AppColor.lightTheme,
        darkTheme: AppColor.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
