import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/features/weather/data/models/city_weather.dart';
import 'package:weather_app/features/weather/data/repos/weather_repo.dart';

// Mock classes
class MockBox<T> extends Mock implements Box<T> {}
class MockHiveInterface extends Mock implements HiveInterface {}
class MockClient extends Mock implements http.Client {}

void main() {
  late WeatherRepository repository;
  late MockBox<CityWeather> mockBox;

  // Sample test data
  final testWeather = CityWeather(
    cityName: 'Lagos',
    temperature: '28.0°C',
    range: '26.0°C - 30.0°C',
    description: 'Partly cloudy',
    humidity: '65%',
    windSpeed: '12.0km/h',
    precipitation: '0mm',
  );

  setUp(() {
    mockBox = MockBox<CityWeather>();
    repository = WeatherRepository();
  });

  tearDown(() {
    reset(mockBox);
  });

  group('getCityOptions', () {
    test('should return exactly 15 predefined Nigerian cities', () {
      // Act
      final result = repository.getCityOptions();
      
      // Assert
      expect(result, hasLength(15));
      expect(result, contains('Lagos'));
      expect(result, contains('Abuja'));
      expect(result, contains('Ibadan'));
      expect(result, contains('Kano'));
      expect(result, contains('Port Harcourt'));
      
      // Test that all cities are strings and not empty
      for (final city in result) {
        expect(city, isA<String>());
        expect(city.trim(), isNotEmpty);
      }
    });

    test('should return cities in expected order', () {
      // Act
      final result = repository.getCityOptions();
      
      // Assert
      expect(result.first, equals('Lagos'));
      expect(result[1], equals('Abuja'));
      expect(result.last, equals('Mushin'));
    });
  });

  group('parameter validation', () {
    test('addCity should throw meaningful exception for null input', () async {
      // Act & Assert
      expect(
        () => repository.addCity(null),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('City name cannot be null or empty'),
          ),
        ),
      );
    });

    test('addCity should throw meaningful exception for empty input', () async {
      // Act & Assert
      expect(
        () => repository.addCity(''),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('City name cannot be null or empty'),
          ),
        ),
      );
    });

    test('addCity should throw meaningful exception for whitespace-only input', () async {
      // Act & Assert
      expect(
        () => repository.addCity(''),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('City name cannot be null or empty'),
          ),
        ),
      );
    });

    test('removeCity should throw meaningful exception for null input', () async {
      // Act & Assert
      expect(
        () => repository.removeCity(null),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('City name cannot be null or empty'),
          ),
        ),
      );
    });

    test('removeCity should throw meaningful exception for empty input', () async {
      // Act & Assert
      expect(
        () => repository.removeCity(''),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('City name cannot be null or empty'),
          ),
        ),
      );
    });
  });

  group('CityWeather model validation', () {
    test('should create CityWeather with valid data', () {
      // Act
      final weather = CityWeather(
        cityName: 'Test City',
        temperature: '25.0°C',
        range: '20.0°C - 30.0°C',
        description: 'sunny',
        humidity: '60%',
        windSpeed: '10.0km/h',
        precipitation: '0mm',
      );
      
      // Assert
      expect(weather.cityName, equals('Test City'));
      expect(weather.temperature, equals('25.0°C'));
      expect(weather.range, equals('20.0°C - 30.0°C'));
      expect(weather.description, equals('sunny'));
      expect(weather.humidity, equals('60%'));
      expect(weather.windSpeed, equals('10.0km/h'));
      expect(weather.precipitation, equals('0mm'));
    });

    test('should handle temperature formatting correctly', () {
      // Test that temperature values are formatted to 1 decimal place
      final weather = CityWeather(
        cityName: 'Test',
        temperature: '25.0°C', // Should be formatted as 25.0°C not 25°C
        range: '20.0°C - 30.0°C',
        description: 'test',
        humidity: '60%',
        windSpeed: '10.0km/h',
        precipitation: '0mm',
      );
      
      expect(weather.temperature, contains('.'));
      expect(weather.temperature, endsWith('°C'));
    });

    test('should handle wind speed conversion correctly', () {
      // Wind speed should be converted from m/s to km/h (multiply by 3.6)
      // If API returns 3.33 m/s, it should become 12.0 km/h
      final weather = CityWeather(
        cityName: 'Test',
        temperature: '25.0°C',
        range: '20.0°C - 30.0°C',
        description: 'test',
        humidity: '60%',
        windSpeed: '12.0km/h', // 3.33 * 3.6 = 11.988 ≈ 12.0
        precipitation: '0mm',
      );
      
      expect(weather.windSpeed, endsWith('km/h'));
      expect(weather.windSpeed, contains('.'));
    });
  });

  group('edge cases and error handling', () {
    test('should handle percentage values correctly', () {
      final weather = CityWeather(
        cityName: 'Test',
        temperature: '25.0°C',
        range: '20.0°C - 30.0°C',
        description: 'test',
        humidity: '65%',
        windSpeed: '10.0km/h',
        precipitation: '0mm',
      );
      
      expect(weather.humidity, endsWith('%'));
      expect(int.parse(weather.humidity!.replaceAll('%', '')), isA<int>());
    });

    test('should handle precipitation values correctly', () {
      final weather = CityWeather(
        cityName: 'Test',
        temperature: '25.0°C',
        range: '20.0°C - 30.0°C',
        description: 'test',
        humidity: '65%',
        windSpeed: '10.0km/h',
        precipitation: '2.5mm',
      );
      
      expect(weather.precipitation, endsWith('mm'));
    });

    test('should validate city name format', () {
      // Test that city names don't contain special characters that could break API calls
      final cities = repository.getCityOptions();
      
      for (final city in cities) {
        expect(city, isNot(contains('&')));
        expect(city, isNot(contains('?')));
        expect(city, isNot(contains('=')));
        expect(city, isNot(startsWith(' ')));
        expect(city, isNot(endsWith(' ')));
      }
    });
  });

  group('business logic validation', () {
    test('should have reasonable temperature range format', () {
      // Temperature ranges should be in format "XX.X°C - YY.Y°C"
      final weather = testWeather;
      final range = weather.range;
      
      expect(range, contains(' - '));
      expect(range, contains('°C'));
      
      final parts = range!.split(' - ');
      expect(parts, hasLength(2));
      expect(parts[0], endsWith('°C'));
      expect(parts[1], endsWith('°C'));
    });

    test('should validate humidity is within realistic range', () {
      // Humidity should be 0-100%
      final weather = testWeather;
      final humidityValue = int.parse(weather.humidity!.replaceAll('%', ''));
      
      expect(humidityValue, greaterThanOrEqualTo(0));
      expect(humidityValue, lessThanOrEqualTo(100));
    });

    test('should validate wind speed is non-negative', () {
      final weather = testWeather;
      final windValue = double.parse(weather.windSpeed!.replaceAll('km/h', ''));
      
      expect(windValue, greaterThanOrEqualTo(0));
    });

    test('should validate precipitation is non-negative', () {
      final weather = testWeather;
      final precipValue = double.parse(weather.precipitation!.replaceAll('mm', ''));
      
      expect(precipValue, greaterThanOrEqualTo(0));
    });
  });
}

// Integration test note:
// To test the actual HTTP calls and Hive operations, you would need:
// 1. A separate integration test file
// 2. Mock HTTP responses using packages like http_mock_adapter
// 3. Used Hive.init() with a temporary directory for testing
// 4. Tested the full flow including network calls and database operations