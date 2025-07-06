import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/core/constants/app_color.dart';
import 'package:weather_app/features/weather/presentation/bloc/weather_bloc.dart';
import 'package:weather_app/features/weather/presentation/widgets/circular_loader.dart';
import 'package:weather_app/features/weather/presentation/widgets/city_add_remove_dialog.dart';
import 'package:weather_app/features/weather/presentation/widgets/header_text.dart';
import 'package:weather_app/features/weather/presentation/widgets/description_text.dart';
import 'package:weather_app/features/weather/data/models/city_weather.dart';

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
  }

  void _showCityDialog(BuildContext context) {
    final bloc = context.read<WeatherBloc>();
    final state = bloc.state;
    final selectedCities = state is WeatherLoaded
        ? state.cities.map((cw) => cw.cityName).cast<String>().toList()
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
    showDialog(
      context: context,
      builder: (context) => CityAddRemoveDialog(
        availableCities: availableCities,
        selectedCities: selectedCities,
      ),
    );
  }

  void _getCurrentLocation() {
    context.read<WeatherBloc>().add(GetCurrentLocation());
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
            final cities = state.cities.length > 3
                ? state.cities.sublist(0, 3)
                : state.cities;
            return _buildWeatherUI(cities);
          }
          return const CircularLoader();
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
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildCitySelector(cities),
                      const SizedBox(height: 40),
                      _buildWeatherDisplay(cities),
                      const SizedBox(height: 30),
                      _buildIndicators(cities.length),
                      const SizedBox(height: 40),
                      _buildWeatherDetails(cities),
                      const SizedBox(height: 20),
                      _buildForecastSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.cardBackgroundDark,
                  AppColor.cardBackgroundDark.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColor.primaryTextDark.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.darkBackground.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _showCityDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor.primaryDarkBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: AppColor.primaryTextDark.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.menu_rounded,
                      color: AppColor.primaryTextDark,
                      size: 22,
                    ),
                  ),
                ),
                HeaderText(
                  text: 'Weather',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColor.primaryTextDark,
                ),
                GestureDetector(
                  onTap: _getCurrentLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColor.accentYellow, AppColor.accentOrange],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.accentYellow.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.my_location,
                          color: AppColor.primaryTextDark,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        DescriptionText(
                          text: 'Current',
                          fontSize: 13,
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
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColor.cardBackgroundDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColor.primaryTextDark.withValues(alpha: 0.2),
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
                      ? cities[_currentCarouselIndex].cityName
                      : 'Lagos',
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.primaryDarkBlue.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColor.primaryTextDark,
                      size: 20,
                    ),
                  ),
                  isExpanded: true,
                  dropdownColor: AppColor.cardBackgroundDark,
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  style: TextStyle(
                    color: AppColor.primaryTextDark,
                    fontSize: 18,
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
                    return DropdownMenuItem<String>(
                      value: value.cityName,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 15),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    value.cityName ==
                                        cities[_currentCarouselIndex].cityName
                                    ? AppColor.accentYellow
                                    : AppColor.secondaryTextDark,
                              ),
                            ),
                            HeaderText(
                              text: value.cityName,
                              fontSize: 16,
                              fontWeight:
                                  value.cityName ==
                                      cities[_currentCarouselIndex].cityName
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color:
                                  value.cityName ==
                                      cities[_currentCarouselIndex].cityName
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
      },
    );
  }

  Widget _buildWeatherDisplay(List<CityWeather> cities) {
    return SizedBox(
      height: 280,
      child: CarouselSlider.builder(
        itemCount: cities.length,
        itemBuilder: (context, index, _) {
          final city = cities[index];
          return _buildWeatherCard(city);
        },
        options: CarouselOptions(
          height: 280,
          enlargeCenterPage: true,
          viewportFraction: 0.85,
          initialPage: _currentCarouselIndex,
          onPageChanged: (index, reason) {
            setState(() {
              _currentCarouselIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildWeatherCard(CityWeather city) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (insertions, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColor.cardBackgroundDark,
                  AppColor.cardBackgroundDark.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppColor.primaryTextDark.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.darkBackground.withValues(alpha: 0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -20,
                  right: -20,
                  child: AnimatedBuilder(
                    animation: _weatherIconAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _weatherIconAnimation.value * 2 * 3.14159,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColor.primaryBlue.withValues(alpha: 0.2),
                                AppColor.primaryDarkBlue.withValues(alpha: 0.2),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 30,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColor.accentYellow, AppColor.accentOrange],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.accentYellow.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.wb_sunny,
                      color: AppColor.primaryTextDark,
                      size: 40,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  right: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      HeaderText(
                        text: city.temperature,
                        fontSize: 64,
                        fontWeight: FontWeight.w100,
                        color: AppColor.primaryTextDark,
                      ),
                      DescriptionText(
                        text: city.description,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColor.secondaryTextDark,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 30,
                  child: HeaderText(
                    text: city.cityName,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primaryTextDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndicators(int itemCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentCarouselIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: index == _currentCarouselIndex
                ? AppColor.accentYellow
                : AppColor.primaryTextDark.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }

  Widget _buildWeatherDetails(List<CityWeather> cities) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColor.cardBackgroundDark,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColor.primaryTextDark.withValues(alpha: 0.2),
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
                text: cities[_currentCarouselIndex].cityName,
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColor.primaryTextDark,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColor.successGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DescriptionText(
                  text: 'Live',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColor.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DescriptionText(
            text: cities[_currentCarouselIndex].range,
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: AppColor.secondaryTextDark,
          ),
          const SizedBox(height: 4),
          DescriptionText(
            text: 'Sunday, July 06, 2025, 12:13 PM WAT',
            fontSize: 14,
            color: AppColor.secondaryTextDark,
          ),
        ],
      ),
    );
  }

  Widget _buildForecastSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColor.cardBackgroundDark,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColor.primaryTextDark.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
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
                      horizontal: 24,
                      vertical: 12,
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
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColor.primaryTextDark.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: DescriptionText(
                      text: 'Hourly forecast',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primaryTextDark,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
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
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColor.primaryTextDark.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: DescriptionText(
                      text: 'Weekly forecast',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primaryTextDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: AppColor.primaryTextDark.withValues(alpha: 0.1),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  'Humidity',
                  '94%',
                  Icons.water_drop,
                  AppColor.primaryBlue,
                ),
                _buildDivider(),
                _buildStatItem(
                  'Wind',
                  '7km/h',
                  Icons.air,
                  AppColor.successGreen,
                ),
                _buildDivider(),
                _buildStatItem(
                  'Rain',
                  '30%',
                  Icons.umbrella,
                  AppColor.primaryDarkBlue,
                ),
              ],
            ),
          ),
        ],
      ),
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        HeaderText(
          text: value,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColor.primaryTextDark,
        ),
        const SizedBox(height: 4),
        DescriptionText(
          text: label,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColor.secondaryTextDark,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 60,
      width: 1,
      color: AppColor.primaryTextDark.withValues(alpha: 0.1),
    );
  }
}
