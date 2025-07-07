import 'package:hive/hive.dart';

part 'city_weather.g.dart';

/// Hive data model for storing weather information for a city.
/// This class is used for local persistence with Hive.
@HiveType(typeId: 0)
class CityWeather extends HiveObject {
  /// The name of the city.
  @HiveField(0)
  final String? cityName;

  /// The current temperature in the city (e.g., "28°C").
  @HiveField(1)
  final String? temperature;

  /// The temperature range for the day (e.g., "25°C - 30°C").
  @HiveField(2)
  final String? range;

  /// A brief description of the weather (e.g., "Sunny", "Cloudy").
  @HiveField(3)
  final String? description;

  /// The humidity percentage (e.g., "78%").
  @HiveField(4)
  final String? humidity;

  /// The wind speed (e.g., "15km/h").
  @HiveField(5)
  final String? windSpeed;

  /// The precipitation chance or amount (e.g., "10%").
  @HiveField(6)
  final String? precipitation;

  /// Creates a [CityWeather] instance with optional values.
  /// Defaults are provided in case data is missing.
  CityWeather({
    this.cityName = 'Unknown',
    this.temperature = '0°C',
    this.range = '0°C - 0°C',
    this.description = 'No data',
    this.humidity = '0%',
    this.windSpeed = '0km/h',
    this.precipitation = '0%',
  });
}
