import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather_app/core/network/api_key.dart';
import 'package:weather_app/features/weather/data/models/city_weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Repository class that handles weather data operations,
/// including Hive persistence, API calls, and geolocation.
class WeatherRepository {
  /// The Hive box name used for storing cities.
  static const String _boxName = 'weather_cities';

  /// Hive box instance for storing [CityWeather] objects.
  late Box<CityWeather> _box;

  /// Checks that latitude and longitude are within valid Earth ranges.
  bool _isValidLocation(double lat, double lon) {
    return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
  }

  /// Checks that location is not the default (0,0) which indicates no valid position.
  bool _isNotDefaultLocation(double lat, double lon) {
    return lat != 0.0 || lon != 0.0;
  }

  /// Initializes the Hive box and seeds with default cities if empty.
  Future<void> initializeHive() async {
    _box = await Hive.openBox<CityWeather>(_boxName);

    // Seed with default cities if the box is empty.
    if (_box.isEmpty) {
      await addCity('Lagos');
      await addCity('Abuja');
    }
  }

  /// Returns a predefined list of city options.
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

  /// Returns all cities persisted in the Hive box.
  List<CityWeather> getPersistedCities() {
    return _box.values.toList();
  }

  /// Adds a default city if the Hive box is empty.
  Future<void> addDefaultCityIfEmpty() async {
    if (_box.isEmpty) {
      await addCity('Lagos');
    }
  }

  /// Fetches weather data for a given [cityName] from OpenWeather API,
  /// then persists it in Hive if not already stored.
  Future<void> addCity(String? cityName) async {
    if (cityName == null || cityName.isEmpty) {
      throw Exception('City name cannot be null or empty');
    }

    // Check if city already exists
    if (!_box.values.map((cw) => cw.cityName).contains(cityName)) {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final weather = CityWeather(
          cityName: data['name'],
          temperature: '${data['main']['temp'].toStringAsFixed(1)}°C',
          range:
              '${data['main']['temp_min'].toStringAsFixed(1)}°C - ${data['main']['temp_max'].toStringAsFixed(1)}°C',
          description: data['weather'][0]['description'],
          humidity: '${data['main']['humidity']}%',
          windSpeed: '${(data['wind']['speed'] * 3.6).toStringAsFixed(1)}km/h', // m/s to km/h
          precipitation: _getPrecipitation(data),
        );

        await _box.add(weather);
      } else {
        throw Exception('Failed to load weather for $cityName');
      }
    }
  }

  /// Extracts precipitation info from API response.
  /// Checks for rain or snow amounts for 1h or 3h if present.
  String _getPrecipitation(Map<String, dynamic> data) {
    if (data['rain'] != null) {
      if (data['rain']['1h'] != null) {
        return '${(data['rain']['1h']).toStringAsFixed(1)}mm';
      }
      if (data['rain']['3h'] != null) {
        return '${(data['rain']['3h']).toStringAsFixed(1)}mm';
      }
    }
    if (data['snow'] != null) {
      if (data['snow']['1h'] != null) {
        return '${(data['snow']['1h']).toStringAsFixed(1)}mm';
      }
      if (data['snow']['3h'] != null) {
        return '${(data['snow']['3h']).toStringAsFixed(1)}mm';
      }
    }
    return '0mm'; // Default fallback if no data
  }

  /// Removes a city from Hive by its name.
  Future<void> removeCity(String? cityName) async {
    if (cityName == null || cityName.isEmpty) {
      throw Exception('City name cannot be null or empty');
    }

    final city = _box.values.firstWhere(
      (cw) => cw.cityName == cityName,
      orElse: () => throw Exception('City not found'),
    );

    await city.delete();
  }

  /// Uses the device's geolocation to fetch weather data for the current location.
  /// Validates coordinates, calls API, and builds a [CityWeather] model.
  Future<CityWeather> getCurrentLocationWeather() async {
    try {
      // Ensure location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable them.');
      }

      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permissions are permanently denied. Enable in app settings.',
        );
      }

      // Get the current location with desired accuracy and timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 15),
        ),
      ).timeout(Duration(seconds: 20));

      debugPrint(
        'Obtained position: Lat=${position.latitude}, Lon=${position.longitude}',
      );

      // Validate coordinates
      if (!_isValidLocation(position.latitude, position.longitude)) {
        throw Exception('Invalid location coordinates received (out of bounds)');
      }
      if (!_isNotDefaultLocation(position.latitude, position.longitude)) {
        throw Exception('Received default (0,0) coordinates - location may not be available');
      }

      // Fetch weather data from OpenWeatherMap API using coordinates
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Location weather data: $data');

        return CityWeather(
          cityName: data['name'] ?? 'Current Location',
          temperature: '${data['main']['temp'].toStringAsFixed(1)}°C',
          range:
              '${data['main']['temp_min'].toStringAsFixed(1)}°C - ${data['main']['temp_max'].toStringAsFixed(1)}°C',
          description: data['weather'][0]['description'] ?? 'Unknown',
          humidity: '${data['main']['humidity']}%',
          windSpeed: '${(data['wind']['speed'] * 3.6).toStringAsFixed(1)}km/h',
          precipitation: _getPrecipitation(data),
        );
      } else {
        throw Exception('Failed to fetch weather for current location');
      }
    } catch (e) {
      debugPrint('Error getting current location weather: $e');
      rethrow; // Propagate error to caller
    }
  }
}
