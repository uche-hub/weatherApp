import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/features/weather/data/models/city_weather.dart';
import 'package:weather_app/features/weather/data/repos/weather_repo.dart';
import 'package:weather_app/features/weather/presentation/bloc/weather_bloc.dart';
import 'package:weather_app/main.dart';

// Mock repository with complete implementation
class MockWeatherRepository implements WeatherRepository {
  final List<CityWeather> _cities = [
    CityWeather(
      cityName: 'Lagos',
      temperature: '30°C',
      range: '25°C - 35°C',
      description: 'Sunny',
      humidity: '65%',
      windSpeed: '12km/h',
      precipitation: '0mm', // Updated from rainProbability
    ),
    CityWeather(
      cityName: 'Abuja',
      temperature: '28°C',
      range: '24°C - 32°C',
      description: 'Partly Cloudy',
      humidity: '70%',
      windSpeed: '10km/h',
      precipitation: '2mm', // Updated from rainProbability
    ),
  ];

  @override
  Future<void> initializeHive() async {}

  @override
  Future<void> addCity(String? cityName) async {
    if (cityName == null) throw Exception('City name cannot be null');
    _cities.add(CityWeather(
      cityName: cityName,
      temperature: '25°C',
      range: '22°C - 28°C',
      description: 'Test City',
      humidity: '60%',
      windSpeed: '8km/h',
      precipitation: '1mm',
    ));
  }

  @override
  Future<void> removeCity(String? cityName) async {
    if (cityName == null) throw Exception('City name cannot be null');
    _cities.removeWhere((city) => city.cityName == cityName);
  }

  @override
  Future<void> addDefaultCityIfEmpty() async {
    if (_cities.isEmpty) {
      await addCity('Lagos');
    }
  }

  @override
  List<String> getCityOptions() {
    return ['Lagos', 'Abuja', 'Port Harcourt', 'Kano'];
  }

  @override
  List<CityWeather> getPersistedCities() => _cities;

  @override
  Future<CityWeather> getCurrentLocationWeather() async {
    return CityWeather(
      cityName: 'Current Location',
      temperature: '27°C',
      range: '24°C - 30°C',
      description: 'Varies',
      humidity: '68%',
      windSpeed: '15km/h',
      precipitation: '0mm',
    );
  }
}

void main() {
  group('Weather App Widget Tests', () {
    late MockWeatherRepository mockRepository;

    setUp(() {
      mockRepository = MockWeatherRepository();
    });

    testWidgets('App loads and displays initial cities', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        BlocProvider(
          create: (_) => WeatherBloc(mockRepository)..add(LoadWeather()),
          child: MyApp(weatherRepository: mockRepository),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.byType(CarouselSlider), findsOneWidget);
      expect(find.text('Lagos'), findsOneWidget);
      expect(find.text('30°C'), findsOneWidget); // Verify temperature displays
      expect(find.text('Sunny'), findsOneWidget); // Verify description
    });

    testWidgets('City management dialog works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        BlocProvider(
          create: (_) => WeatherBloc(mockRepository)..add(LoadWeather()),
          child: MyApp(weatherRepository: mockRepository),
        ),
      );
      await tester.pumpAndSettle();

      // Open city management dialog
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify dialog content
      expect(find.text('Manage Cities'), findsOneWidget);
      expect(find.text('Selected Cities'), findsOneWidget);
      expect(find.text('Available Cities'), findsOneWidget);
      expect(find.text('Lagos'), findsNWidgets(2)); // In both lists
      expect(find.text('Port Harcourt'), findsOneWidget); // Available city
    });

    testWidgets('Weather stats display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        BlocProvider(
          create: (_) => WeatherBloc(mockRepository)..add(LoadWeather()),
          child: MyApp(weatherRepository: mockRepository),
        ),
      );
      await tester.pumpAndSettle();

      // Verify weather stats are displayed
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('65%'), findsOneWidget); // Lagos humidity
      expect(find.text('Wind'), findsOneWidget);
      expect(find.text('12km/h'), findsOneWidget); // Lagos wind speed
      expect(find.text('Precipitation'), findsOneWidget); // Updated from Rain
      expect(find.text('0mm'), findsOneWidget); // Lagos precipitation
    });

    testWidgets('Current location button works', (WidgetTester tester) async {
      await tester.pumpWidget(
        BlocProvider(
          create: (_) => WeatherBloc(mockRepository)..add(LoadWeather()),
          child: MyApp(weatherRepository: mockRepository),
        ),
      );
      await tester.pumpAndSettle();

      // Tap current location button
      await tester.tap(find.text('Current'));
      await tester.pumpAndSettle();

      // Verify current location weather loads
      expect(find.text('Current Location'), findsOneWidget);
    });
  });
}