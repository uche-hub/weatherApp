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

### Color Theme
The app uses a consistent color theme defined in `lib/core/constants/app_color.dart`. It includes:
- Primary colors (blues for sky, yellows/oranges for sun).
- Background and card colors for light and dark modes.
- Text colors for readability.
- A gradient for weather cards.
- Support for dynamic theme switching based on device brightness.

### Navigation
The app uses the `go_router` package for type-safe navigation. Routes are defined in `lib/core/constants/route.dart`, with path constants in `lib/core/constants/route_path.dart`. Key routes:
- `/`: HomeScreen (displays weather carousel).
- `/city-selection`: CitySelectionScreen (add/remove cities).

### Widgets
The app includes reusable UI components in `lib/features/weather/presentation/widgets/`:
- `header_text.dart`: A customizable widget for displaying titles using Google Fonts' Roboto, with bold styling and theme-aware colors.
- `description_text.dart`: A widget for displaying description text using Google Fonts' Open Sans, with secondary styling, supporting truncation and alignment.
- `custom_toast.dart`: A utility for showing success or failure toast messages with icons, styled with theme-aware colors.
- `horizontal_loader.dart`: A linear progress indicator for button loading states, using the app's primary color.
- `circular_loader.dart`: A clean circular progress indicator for screen or widget loading, with customizable size and stroke width.
- `custom_app_bar.dart`: A transparent app bar with customizable title and actions, using Google Fonts' Roboto.

### State Management
The app uses the BLoC pattern for state management, implemented in `lib/features/weather/presentation/bloc/`:
- `weather_bloc.dart`: Manages fetching and displaying weather data for cities and current location.
- `city_bloc.dart`: Handles adding, removing, and persisting selected cities (up to 3).
- `location_bloc.dart`: Manages fetching the device's current location.
Mock repositories in `lib/features/weather/data/mock_repositories.dart` simulate data fetching and persistence for development.

## ✅ Automated Tests

This project includes a widget test to verify that the `WeatherBloc` correctly loads weather data and updates the UI.

**What it tests:**
- When the app starts, it dispatches `LoadWeather` to the `WeatherBloc`.
- It shows a loader and then displays the default city ("Lagos").
- It displays the weather carousel and the menu icon.
- Tapping the menu shows the **Manage Cities** dialog with the correct available cities.


### Dependencies
- `flutter_bloc`: For state management.
- `http`: For API requests to OpenWeatherMap.
- `geolocator`: For fetching the device's current location.
- `shared_preferences` or `hive`: For persisting selected cities.
- `equatable`: For comparing objects in BLoC states.
- `mockito` and `test`: For unit testing.
- `get_it`: For dependency injection.
- `carousel_slider`: For carousel view in HomeScreen.
- `go_router`: For navigation.
- `google_fonts`: For custom typography (Roboto and Open Sans).

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