import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/features/weather/data/models/city_weather.dart';
import 'package:weather_app/features/weather/data/repos/weather_repo.dart';

abstract class WeatherEvent {}

class LoadWeather extends WeatherEvent {}

class AddCity extends WeatherEvent {
  final String cityName;
  AddCity(this.cityName);
}

class RemoveCity extends WeatherEvent {
  final String cityName;
  RemoveCity(this.cityName);
}

class GetCurrentLocation extends WeatherEvent {}

abstract class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final List<CityWeather> cities;
  WeatherLoaded(this.cities);
}

class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);
}

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc(this.weatherRepository) : super(WeatherInitial()) {
    on<LoadWeather>(_onLoadWeather);
    on<AddCity>(_onAddCity);
    on<RemoveCity>(_onRemoveCity);
    on<GetCurrentLocation>(_onGetCurrentLocation);

    weatherRepository.initializeHive();
  }

  /// ✅✅✅ FIXED: Correctly re-fetch cities AFTER adding defaults.
  Future<void> _onLoadWeather(LoadWeather event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      var cities = weatherRepository.getPersistedCities();
      if (cities.isEmpty) {
        await weatherRepository.addCity('Lagos');
        await weatherRepository.addCity('Abuja');
        await weatherRepository.addCity('Port Harcourt');
        // ✅ Fetch again after adding.
        cities = weatherRepository.getPersistedCities();
      }
      emit(WeatherLoaded(cities));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  Future<void> _onAddCity(AddCity event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      await weatherRepository.addCity(event.cityName);
      final cities = weatherRepository.getPersistedCities();
      emit(WeatherLoaded(cities));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  Future<void> _onRemoveCity(RemoveCity event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      await weatherRepository.removeCity(event.cityName);
      final cities = weatherRepository.getPersistedCities();
      emit(WeatherLoaded(cities));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  Future<void> _onGetCurrentLocation(GetCurrentLocation event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      final weather = await weatherRepository.getCurrentLocationWeather();
      await weatherRepository.addCity(weather.cityName);
      final cities = weatherRepository.getPersistedCities();
      emit(WeatherLoaded(cities));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }
}
