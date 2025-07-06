import 'package:hive/hive.dart';

part 'city_weather.g.dart';

@HiveType(typeId: 0)
class CityWeather extends HiveObject {
  @HiveField(0)
  final String cityName;

  @HiveField(1)
  final String temperature;

  @HiveField(2)
  final String range;

  @HiveField(3)
  final String description;

  CityWeather({
    required this.cityName,
    required this.temperature,
    required this.range,
    required this.description,
  });
}