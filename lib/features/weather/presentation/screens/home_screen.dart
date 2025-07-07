import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/core/constants/app_color.dart';
import 'package:weather_app/features/weather/presentation/bloc/weather_bloc.dart';
import 'package:weather_app/features/weather/presentation/widgets/circular_loader.dart';
import 'package:weather_app/features/weather/presentation/widgets/city_add_remove_dialog.dart';
import 'package:weather_app/features/weather/presentation/widgets/custom_toast.dart'
    as custom_toast;
import 'package:weather_app/features/weather/presentation/widgets/header_text.dart';
import 'package:weather_app/features/weather/presentation/widgets/description_text.dart';
import 'package:weather_app/features/weather/data/models/city_weather.dart';

// This is the main screen of the weather app, handling the UI and city management.
// It uses animations, a carousel for city weather display, and integrates with WeatherBloc for state management.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _weatherIconController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _weatherIconAnimation;
  int _currentCarouselIndex = 0;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Initialize animation controllers for fade, slide, pulse, and weather icon effects.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _weatherIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _weatherIconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _weatherIconController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
    _weatherIconController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _weatherIconController.dispose();
    super.dispose();
    // Dispose of animation controllers to prevent memory leaks.
  }

  String _formatCurrentDateTime() {
    final now = DateTime.now();
    // Format: Monday, July 07, 2025, 11:21 AM WAT
    final dayName = _getWeekdayName(now.weekday);
    final monthName = _getMonthName(now.month);
    final day = now.day.toString().padLeft(2, '0');
    final year = now.year;
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour >= 12 ? 'PM' : 'AM';

    // Add your timezone manually or from DateTime if needed
    const timezone = 'WAT';

    return '$dayName, $monthName $day, $year, $hour:$minute $amPm $timezone';
  }

  String _getWeekdayName(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[(weekday - 1) % 7];
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[(month - 1) % 12];
  }

  void _showCityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          final selectedCities = state is WeatherLoaded
              ? state.cities
                    .map((cw) => cw.cityName ?? 'Unknown')
                    .cast<String>()
                    .toList()
              : <String>[];
          final availableCities = [
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
          ]..removeWhere((city) => selectedCities.contains(city));
          return CityAddRemoveDialog(
            initialAvailableCities: availableCities,
            initialSelectedCities: selectedCities,
            onCitySelected: (city) {
              if (mounted) {
                context.read<WeatherBloc>().add(AddCity(city));
                custom_toast.CustomToast.show(
                  context: context,
                  message: '$city has been added',
                  type: custom_toast.ToastType.success,
                );
              }
            },
            onCityRemoved: (city) {
              if (mounted) {
                context.read<WeatherBloc>().add(RemoveCity(city));
                custom_toast.CustomToast.show(
                  context: context,
                  message: '$city has been removed',
                  type: custom_toast.ToastType.failure,
                );
                if (state is WeatherLoaded &&
                    _currentCarouselIndex >= state.cities.length - 1) {
                  setState(() {
                    _currentCarouselIndex = state.cities.length > 1
                        ? state.cities.length - 2
                        : 0;
                  });
                }
              }
            },
          );
          // Show dialog for managing cities, updating based on current bloc state.
        },
      ),
    );
  }

  void _getCurrentLocation() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Get location
      final bloc = context.read<WeatherBloc>();
      bloc.add(GetCurrentLocation());

      // Wait a bit before closing dialog to ensure smooth UX
      await Future.delayed(Duration(milliseconds: 500));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting location: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoading) return const CircularLoader();
          if (state is WeatherError) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColor.primaryDarkBlue, AppColor.darkBackground],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColor.errorRed,
                    ),
                    const SizedBox(height: 16),
                    DescriptionText(
                      text: state.message,
                      color: AppColor.primaryTextDark,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is WeatherLoaded) {
            final cities = state.cities;
            if (_currentCarouselIndex >= cities.length) {
              setState(() {
                _currentCarouselIndex = cities.isNotEmpty
                    ? cities.length - 1
                    : 0;
              });
            }
            return _buildWeatherUI(cities);
          }
          return const CircularLoader();
          // Build UI based on WeatherBloc state, handling loading, error, and loaded states.
        },
      ),
    );
  }

  Widget _buildWeatherUI(List<CityWeather> cities) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primaryBlue,
            AppColor.primaryDarkBlue,
            AppColor.darkBackground,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildModernAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        _buildCitySelector(cities),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                          child: _buildWeatherDisplay(cities),
                        ),
                        const SizedBox(height: 10),
                        _buildIndicators(cities.length),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                          child: _buildWeatherDetails(
                            cities[_currentCarouselIndex],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: _buildForecastSection(
                            cities[_currentCarouselIndex],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Main UI container with gradient background and animated content.
    );
  }

  Widget _buildModernAppBar() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.cardBackgroundDark,
                  AppColor.cardBackgroundDark.withAlpha(153),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColor.primaryTextDark.withAlpha(51),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.darkBackground.withAlpha(77),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _showCityDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColor.primaryDarkBlue.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColor.primaryTextDark.withAlpha(77),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.menu_rounded,
                      color: AppColor.primaryTextDark,
                      size: 20,
                    ),
                  ),
                ),
                HeaderText(
                  text: 'Weather',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColor.primaryTextDark,
                ),
                GestureDetector(
                  onTap: _getCurrentLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColor.accentYellow, AppColor.accentOrange],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.accentYellow.withAlpha(102),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.my_location,
                          color: AppColor.primaryTextDark,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        DescriptionText(
                          text: 'Current',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColor.primaryTextDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCitySelector(List<CityWeather> cities) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 1.5),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColor.cardBackgroundDark,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColor.primaryTextDark.withAlpha(51),
                width: 1,
              ),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(canvasColor: AppColor.darkBackground),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: cities.isNotEmpty
                      ? (cities[_currentCarouselIndex].cityName ?? 'Unknown')
                      : 'Lagos',
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColor.primaryDarkBlue.withAlpha(77),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColor.primaryTextDark,
                      size: 18,
                    ),
                  ),
                  isExpanded: true,
                  dropdownColor: AppColor.cardBackgroundDark,
                  borderRadius: BorderRadius.circular(15),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  style: TextStyle(
                    color: AppColor.primaryTextDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _currentCarouselIndex = cities.indexWhere(
                          (city) => city.cityName == newValue,
                        );
                      });
                    }
                  },
                  items: cities.map<DropdownMenuItem<String>>((
                    CityWeather value,
                  ) {
                    final cityName = value.cityName ?? 'Unknown';
                    return DropdownMenuItem<String>(
                      value: cityName,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    cityName ==
                                        (cities[_currentCarouselIndex]
                                                .cityName ??
                                            'Unknown')
                                    ? AppColor.accentYellow
                                    : AppColor.secondaryTextDark,
                              ),
                            ),
                            HeaderText(
                              text: cityName,
                              fontSize: 14,
                              fontWeight:
                                  cityName ==
                                      (cities[_currentCarouselIndex].cityName ??
                                          'Unknown')
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color:
                                  cityName ==
                                      (cities[_currentCarouselIndex].cityName ??
                                          'Unknown')
                                  ? AppColor.primaryTextDark
                                  : AppColor.secondaryTextDark,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
        // City selector dropdown with animated slide effect and dynamic city list.
      },
    );
  }

  Widget _buildWeatherDisplay(List<CityWeather> cities) {
    return CarouselSlider.builder(
      itemCount: cities.length,
      itemBuilder: (context, index, _) {
        final city = cities[index];
        return _buildWeatherCard(city);
      },
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.35,
        enlargeCenterPage: true,
        viewportFraction: 0.85,
        initialPage: _currentCarouselIndex,
        onPageChanged: (index, reason) {
          setState(() {
            _currentCarouselIndex = index;
          });
        },
      ),
      // Carousel slider to display weather cards for all selected cities.
    );
  }

  Widget _buildWeatherCard(CityWeather city) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColor.cardBackgroundDark,
                  AppColor.cardBackgroundDark.withAlpha(179),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColor.primaryTextDark.withAlpha(51),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.darkBackground.withAlpha(77),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -15,
                  right: -15,
                  child: AnimatedBuilder(
                    animation: _weatherIconAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _weatherIconAnimation.value * 2 * 3.14159,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColor.primaryBlue.withAlpha(51),
                                AppColor.primaryDarkBlue.withAlpha(51),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColor.accentYellow, AppColor.accentOrange],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.accentYellow.withAlpha(102),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.wb_sunny,
                      color: AppColor.primaryTextDark,
                      size: 30,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      HeaderText(
                        text: city.temperature ?? '0°C',
                        fontSize: 48,
                        fontWeight: FontWeight.w100,
                        color: AppColor.primaryTextDark,
                      ),
                      DescriptionText(
                        text: city.description ?? 'No data',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColor.secondaryTextDark,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 15,
                  left: 20,
                  child: HeaderText(
                    text: city.cityName ?? 'Unknown',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primaryTextDark,
                  ),
                ),
              ],
            ),
          ),
        );
        // Weather card with animated pulse effect, displaying temperature and description.
      },
    );
  }

  Widget _buildIndicators(int itemCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: index == _currentCarouselIndex ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: index == _currentCarouselIndex
                ? AppColor.accentYellow
                : AppColor.primaryTextDark.withAlpha(77),
          ),
        );
      }),
      // Indicators for the carousel, highlighting the current city.
    );
  }

  Widget _buildWeatherDetails(CityWeather city) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.cardBackgroundDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColor.primaryTextDark.withAlpha(51),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HeaderText(
                text: city.cityName ?? 'Unknown',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColor.primaryTextDark,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColor.successGreen.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DescriptionText(
                  text: 'Live',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColor.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          DescriptionText(
            text: city.range ?? '0°C - 0°C',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColor.secondaryTextDark,
          ),
          const SizedBox(height: 3),
          DescriptionText(
            text: _formatCurrentDateTime(),
            fontSize: 10,
            color: AppColor.secondaryTextDark,
          ),
        ],
      ),
      // Weather details section with city name, temperature range, and current date/time.
    );
  }

  Widget _buildForecastSection(CityWeather city) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColor.cardBackgroundDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColor.primaryTextDark.withAlpha(51),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: !_isExpanded
                          ? LinearGradient(
                              colors: [
                                AppColor.primaryBlue,
                                AppColor.primaryDarkBlue,
                              ],
                            )
                          : null,
                      color: _isExpanded ? Colors.transparent : null,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColor.primaryTextDark.withAlpha(51),
                        width: 1,
                      ),
                    ),
                    child: DescriptionText(
                      text: 'Hourly forecast',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primaryTextDark,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: _isExpanded
                          ? LinearGradient(
                              colors: [
                                AppColor.primaryBlue,
                                AppColor.primaryDarkBlue,
                              ],
                            )
                          : null,
                      color: !_isExpanded ? Colors.transparent : null,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColor.primaryTextDark.withAlpha(51),
                        width: 1,
                      ),
                    ),
                    child: DescriptionText(
                      text: 'Weekly forecast',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primaryTextDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColor.primaryTextDark.withAlpha(26)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  'Humidity',
                  city.humidity ?? '0%',
                  Icons.water_drop,
                  AppColor.primaryBlue,
                ),
                _buildDivider(),
                _buildStatItem(
                  'Wind',
                  city.windSpeed ?? '0km/h',
                  Icons.air,
                  AppColor.successGreen,
                ),
                _buildDivider(),
                _buildStatItem(
                  'Precipitation',
                  city.precipitation ?? '0mm',
                  Icons.umbrella,
                  AppColor.primaryDarkBlue,
                ),
              ],
            ),
          ),
        ],
      ),
      // Forecast section with toggleable hourly/weekly view and weather stats.
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 8),
        HeaderText(
          text: value,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColor.primaryTextDark,
        ),
        const SizedBox(height: 3),
        DescriptionText(
          text: label,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColor.secondaryTextDark,
        ),
      ],
      // Stat item widget for displaying weather metrics like humidity, wind, and rain.
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColor.primaryTextDark.withAlpha(26),
      // Divider between stat items in the forecast section.
    );
  }
}
