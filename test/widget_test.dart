import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/features/weather/data/models/city_weather.dart';
import 'package:weather_app/features/weather/data/repos/weather_repo.dart';
import 'package:weather_app/features/weather/presentation/bloc/weather_bloc.dart';
import 'package:weather_app/main.dart';

// ✅ Put FakeWeatherRepository here
class FakeWeatherRepository implements WeatherRepository {
  @override
  Future<void> initializeHive() async {}

  @override
  Future<void> addCity(String cityName) async {}

  @override
  Future<void> removeCity(String cityName) async {}

  @override
  Future<void> addDefaultCityIfEmpty() async {
    // Do nothing for test
  }

  @override
  List<String> getCityOptions() {
    return ['Lagos', 'Abuja'];
  }

  @override
  List<CityWeather> getPersistedCities() {
    return [
      CityWeather(
        cityName: 'Lagos',
        temperature: '30°',
        range: '25° – 35°',
        description: 'Sunny',
      ),
    ];
  }

  @override
  Future<CityWeather> getCurrentLocationWeather() async {
    return CityWeather(
      cityName: 'Current Location',
      temperature: '28°',
      range: '24° – 32°',
      description: 'Varies',
    );
  }
}

void main() {
  testWidgets('Weather app loads initial cities', (WidgetTester tester) async {
    debugPrint('Starting test...');

    final fakeWeatherRepository = FakeWeatherRepository();

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => WeatherBloc(fakeWeatherRepository)..add(LoadWeather()),
        child: MyApp(weatherRepository: fakeWeatherRepository),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();
    debugPrint('Built widget tree.');
    expect(find.byType(CarouselSlider), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Manage Cities'), findsOneWidget);
    expect(find.text('Lagos'), findsNothing);
    expect(find.text('Abuja'), findsOneWidget);
  });
}
