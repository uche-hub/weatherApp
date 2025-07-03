# Weather App

A Flutter-based weather application that fetches and displays current weather data for selected Nigerian cities using the OpenWeatherMap API. The app features a clean architecture, BLoC state management, and a user-friendly interface with a carousel/tab view for weather data, city selection, and current location weather.

## Features
- Select from 15 predefined Nigerian cities to view current weather data.
- Display weather for up to 3 cities in a carousel/tab view.
- Add/remove cities from the carousel with persistence across app restarts.
- Fetch weather data for the user's current location using geolocation.
- Clean architecture with separation of concerns.
- Unit tests for BLoCs, use cases, repositories, and data sources.
- Responsive UI with smooth animations and error handling.

## Architecture

The app follows a **Clean Architecture** approach with **BLoC** for state management, ensuring separation of concerns, testability, and maintainability. It is divided into three layers: **Presentation**, **Domain**, and **Data**.

### Architecture Layers

#### 1. Presentation Layer
- **Responsibility**: Handles UI components, user interactions, and state rendering.
- **Components**:
  - **Widgets**: Flutter widgets for the UI (e.g., city selection dropdown, carousel/tab view, current location button).
  - **BLoC**: Manages UI state and events using the `flutter_bloc` package.
    - `WeatherBloc`: Handles weather data fetching and city selection logic.
    - `CityBloc`: Manages the list of cities in the carousel and persistence.
    - `LocationBloc`: Handles geolocation fetching and weather data for the current location.
  - **Screens**:
    - `HomeScreen`: Displays the carousel/tab view with weather data for selected cities.
    - `CitySelectionScreen`: Allows users to add/remove cities from the carousel.
  - **UI Features**:
    - Carousel/tab view for 3 cities' weather data.
    - Dropdown for selecting from 15 predefined Nigerian cities.
    - Button to fetch weather for the current location.
    - Smooth transitions when changing city selections.

#### 2. Domain Layer
- **Responsibility**: Contains business logic, use cases, and entities. Independent of any framework or external services.
- **Components**:
  - **Entities**:
    - `Weather`: Represents weather data (e.g., temperature, humidity, description).
    - `City`: Represents a city with name, latitude, and longitude.
    - `Location`: Represents geolocation coordinates (latitude, longitude).
  - **Use Cases**:
    - `GetWeatherForCity`: Fetches weather data for a specific city.
    - `GetWeatherForLocation`: Fetches weather data for the current location.
    - `ManageCities`: Adds/removes cities from the carousel and persists them.
    - `GetCurrentLocation`: Retrieves the device's geolocation.
  - **Repositories (Abstract)**:
    - `WeatherRepository`: Interface for weather data operations.
    - `CityRepository`: Interface for city list persistence.
    - `LocationRepository`: Interface for geolocation operations.

#### 3. Data Layer
- **Responsibility**: Handles data sources, API calls, and persistence.
- **Components**:
  - **Models**: Data transfer objects (DTOs) that map API responses to entities (e.g., `WeatherModel`, `CityModel`).
  - **Data Sources**:
    - **Remote Data Source**: Interacts with the OpenWeatherMap API to fetch weather data.
      - `WeatherApiService`: Makes HTTP requests to the OpenWeatherMap API (using `http` package).
    - **Local Data Source**: Persists selected cities using `shared_preferences` or `hive` for lightweight storage.
      - `CityLocalDataSource`: Saves and retrieves the list of cities in the carousel.
    - **Geolocation Data Source**: Uses the `geolocator` package to fetch the device's current location.
  - **Repositories (Implementation)**:
    - `WeatherRepositoryImpl`: Implements `WeatherRepository` to fetch weather data from the API.
    - `CityRepositoryImpl`: Implements `CityRepository` to manage city persistence.
    - `LocationRepositoryImpl`: Implements `LocationRepository` to handle geolocation.

### Folder Structure
weather_app/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── cities.dart
│   │   ├── error/
│   │   │   └── failures.dart
│   │   └── network/
│   │       └── network_info.dart
│   ├── features/
│   │   ├── weather/
│   │   │   ├── presentation/
│   │   │   │   ├── bloc/
│   │   │   │   │   ├── weather_bloc.dart
│   │   │   │   │   ├── city_bloc.dart
│   │   │   │   │   └── location_bloc.dart
│   │   │   │   ├── screens/
│   │   │   │   │   ├── home_screen.dart
│   │   │   │   │   └── city_selection_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── weather_card.dart
│   │   │   │       └── carousel_view.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── weather.dart
│   │   │   │   │   ├── city.dart
│   │   │   │   │   └── location.dart
│   │   │   │   ├── usecases/
│   │   │   │   │   ├── get_weather_for_city.dart
│   │   │   │   │   ├── get_weather_for_location.dart
│   │   │   │   │   ├── manage_cities.dart
│   │   │   │   │   └── get_current_location.dart
│   │   │   │   └── repositories/
│   │   │   │       ├── weather_repository.dart
│   │   │   │       ├── city_repository.dart
│   │   │   │       └── location_repository.dart
│   │   │   └── data/
│   │   │       ├── models/
│   │   │       │   ├── weather_model.dart
│   │   │       │   └── city_model.dart
│   │   │       ├── datasources/
│   │   │       │   ├── weather_api_service.dart
│   │   │       │   ├── city_local_datasource.dart
│   │   │       │   └── location_datasource.dart
│   │   │       └── repositories/
│   │   │           ├── weather_repository_impl.dart
│   │   │           ├── city_repository_impl.dart
│   │   │           └── location_repository_impl.dart
│   ├── di/
│   │   └── injection_container.dart
│   ├── app.dart
│   └── main.dart
├── test/
│   ├── features/
│   │   ├── weather/
│   │   │   ├── presentation/
│   │   │   │   └── bloc/
│   │   │   │       ├── weather_bloc_test.dart
│   │   │   │       ├── city_bloc_test.dart
│   │   │   │       └── location_bloc_test.dart
│   │   │   ├── domain/
│   │   │   │   └── usecases/
│   │   │   │       ├── get_weather_for_city_test.dart
│   │   │   │       ├── get_weather_for_location_test.dart
│   │   │   │       ├── manage_cities_test.dart
│   │   │   │       └── get_current_location_test.dart
│   │   │   └── data/
│   │   │       ├── datasources/
│   │   │       │   ├── weather_api_service_test.dart
│   │   │       │   ├── city_local_datasource_test.dart
│   │   │       │   └── location_datasource_test.dart
│   │   │       └── repositories/
│   │   │           ├── weather_repository_impl_test.dart
│   │   │           ├── city_repository_impl_test.dart
│   │   │           └── location_repository_impl_test.dart
├── pubspec.yaml


### Dependencies
- `flutter_bloc`: For state management.
- `http`: For API requests to OpenWeatherMap.
- `geolocator`: For fetching the device's current location.
- `shared_preferences` or `hive`: For persisting selected cities.
- `equatable`: For comparing objects in BLoC states.
- `mockito` and `test`: For unit testing.
- `get_it`: For dependency injection.
- `carousel_slider`: For carousel view.

### Predefined Cities
The app includes the following 15 Nigerian cities:
1. Lagos (Default)
2. Abuja
3. Port Harcourt
4. Kano
5. Ibadan
6. Kaduna
7. Enugu
8. Benin City
9. Jos
10. Ilorin
11. Owerri
12. Warri
13. Abeokuta
14. Zaria
15. Maiduguri

### API
- **Base URL**: [OpenWeatherMap](https://openweathermap.org/)
- **Endpoint**: [Current Weather API](https://openweathermap.org/current)