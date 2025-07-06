import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather_app/features/weather/data/models/city_weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherRepository {
  static const String _boxName = 'weather_cities'; // ✅ MATCH main.dart

  Future<void> initializeHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CityWeatherAdapter());
    await Hive.openBox<CityWeather>(_boxName);
  }

  Box<CityWeather> get _box => Hive.box<CityWeather>(_boxName);

  List<String> getCityOptions() {
    return [
      'Lagos',
      'Abuja',
      'Ibadan',
      'Awka',
      'Kano',
      'Port Harcourt',
      'Nneyi-Umuleri',
      'Onitsha',
      'Maiduguri',
      'Aba',
      'Benin City',
      'Shagamu',
      'Ikare',
      'Ogbomoso',
      'Mushin',
    ];
  }

  List<CityWeather> getPersistedCities() {
    return _box.values.toList();
  }

  Future<void> addDefaultCityIfEmpty() async {
    if (_box.isEmpty) {
      await addCity('Lagos');
    }
  }

  Future<void> addCity(String cityName) async {
    if (!_box.values.map((cw) => cw.cityName).contains(cityName)) {
      final weather = CityWeather(
        cityName: cityName,
        temperature: '${(20 + DateTime.now().millisecond % 15)}°',
        range:
            '${(15 + DateTime.now().millisecond % 10)}° – ${(25 + DateTime.now().millisecond % 10)}°',
        description: [
          'Sunny',
          'Cloudy',
          'Rainy',
          'Partly cloudy',
        ][DateTime.now().millisecond % 4],
      );
      await _box.add(weather);
    }
  }

  Future<void> removeCity(String cityName) async {
    final city = _box.values.firstWhere(
      (cw) => cw.cityName == cityName,
      orElse: () => throw Exception('City not found'),
    );
    await city.delete();
  }

  Future<CityWeather> getCurrentLocationWeather() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    final position = await Geolocator.getCurrentPosition();
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=your_api_key_here&units=metric'));
    if (response.statusCode == 200) {
      return CityWeather(
        cityName: 'Current Location',
        temperature: '${(position.latitude * 2).toStringAsFixed(0)}°',
        range:
            '${(position.latitude * 1.5).toStringAsFixed(0)}° – ${(position.latitude * 2.5).toStringAsFixed(0)}°',
        description: 'Varies',
      );
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
