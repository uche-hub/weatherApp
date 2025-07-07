import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/features/weather/data/models/city_weather.dart';
import 'package:weather_app/features/weather/data/repos/weather_repo.dart';

/// Base class for all weather-related events.
abstract class WeatherEvent {}

/// Event to load weather data for all persisted cities.
class LoadWeather extends WeatherEvent {}

/// Event to add a new city to the weather list.
class AddCity extends WeatherEvent {
  final String? cityName;

  AddCity(this.cityName);
}

/// Event to remove a city from the weather list.
class RemoveCity extends WeatherEvent {
  final String? cityName;

  RemoveCity(this.cityName);
}

/// Event to get weather for the user's current geolocation.
class GetCurrentLocation extends WeatherEvent {}

/// Base class for all possible weather states.
abstract class WeatherState {}

/// Initial state when nothing has been loaded yet.
class WeatherInitial extends WeatherState {}

/// State to indicate data is being loaded.
class WeatherLoading extends WeatherState {}

/// State to hold the loaded list of cities.
class WeatherLoaded extends WeatherState {
  final List<CityWeather> cities;

  WeatherLoaded(this.cities);
}

/// State to indicate an error occurred.
class WeatherError extends WeatherState {
  final String message;

  WeatherError(this.message);
}

/// The BLoC class handles weather events and emits new states.
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  /// The repository that handles weather data operations.
  final WeatherRepository weatherRepository;

  /// Constructor registers event handlers and initializes Hive.
  WeatherBloc(this.weatherRepository) : super(WeatherInitial()) {
    on<LoadWeather>(_onLoadWeather);
    on<AddCity>(_onAddCity);
    on<RemoveCity>(_onRemoveCity);
    on<GetCurrentLocation>(_onGetCurrentLocation);

    // Initialize Hive storage for city weather persistence.
    weatherRepository.initializeHive();
  }

  /// Handles loading weather for all persisted cities.
  Future<void> _onLoadWeather(
    LoadWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());
    try {
      var cities = weatherRepository.getPersistedCities();

      // If no cities exist, add default cities.
      if (cities.isEmpty) {
        await weatherRepository.addCity('Lagos');
        await weatherRepository.addCity('Abuja');
        await weatherRepository.addCity('Port Harcourt');
        cities = weatherRepository.getPersistedCities();
      }

      emit(WeatherLoaded(cities));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  /// Handles adding a new city to the list.
  Future<void> _onAddCity(AddCity event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      if (event.cityName == null || event.cityName!.isEmpty) {
        emit(WeatherError('City name cannot be null or empty'));
        return;
      }

      await weatherRepository.addCity(event.cityName);

      final cities = weatherRepository.getPersistedCities();
      emit(WeatherLoaded(cities));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  /// Handles removing a city from the list.
  Future<void> _onRemoveCity(
    RemoveCity event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());
    try {
      if (event.cityName == null || event.cityName!.isEmpty) {
        emit(WeatherError('City name cannot be null or empty'));
        return;
      }

      await weatherRepository.removeCity(event.cityName);

      final cities = weatherRepository.getPersistedCities();
      emit(WeatherLoaded(cities));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  /// Handles getting weather data for the user's current location.
  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());
    try {
      final weather = await weatherRepository.getCurrentLocationWeather();

      // Check that the retrieved weather data has a valid city name.
      if (weather.cityName == null || weather.cityName!.isEmpty) {
        emit(WeatherError('Failed to determine location name'));
        return;
      }

      // Add the city to the list if it's not already present.
      final currentCities = state is WeatherLoaded
          ? (state as WeatherLoaded).cities
          : [];

      if (!currentCities.any((c) => c.cityName == weather.cityName)) {
        await weatherRepository.addCity(weather.cityName!);
      }

      emit(WeatherLoaded(weatherRepository.getPersistedCities()));
    } catch (e) {
      debugPrint('Location error: $e');
      emit(WeatherError('Could not get current location: ${e.toString()}'));
    }
  }
}
