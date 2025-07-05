import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/core/constants/app_color.dart';
import 'package:weather_app/features/weather/presentation/bloc/weather_bloc.dart';
import 'package:weather_app/features/weather/presentation/widgets/circular_loader.dart';
import 'package:weather_app/features/weather/presentation/widgets/city_add_remove_dialog.dart';
import 'package:weather_app/features/weather/data/models/city_weather.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
      backgroundColor: AppColor.darkBackground,
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoading) return const CircularLoader();
          if (state is WeatherError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: AppColor.errorRed),
              ),
            );
          }
          if (state is WeatherLoaded) {
            final cities = state.cities.length > 3
                ? state.cities.sublist(0, 3)
                : state.cities;
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Custom app bar with menu and current location
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColor.weatherGradient,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.menu,
                            color: AppColor.primaryTextDark,
                            size: 24,
                          ),
                          onPressed: () => _showCityDialog(context),
                        ),
                        ElevatedButton(
                          onPressed: _getCurrentLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.accentYellow,
                            foregroundColor: AppColor.primaryTextDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Current Location',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Beautiful dropdown
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select City',
                                style: TextStyle(
                                  color: AppColor.secondaryTextDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColor.cardBackgroundDark.withAlpha(
                                    102,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColor.secondaryTextDark.withAlpha(
                                      51,
                                    ),
                                    width: 0.5,
                                  ),
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: AppColor.cardBackgroundDark,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: cities.isNotEmpty
                                          ? cities[_currentCarouselIndex]
                                                .cityName
                                          : 'Lagos',
                                      icon: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppColor.primaryBlue.withAlpha(
                                            77,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: AppColor.primaryTextDark,
                                          size: 20,
                                        ),
                                      ),
                                      iconSize: 32,
                                      elevation: 16,
                                      style: TextStyle(
                                        color: AppColor.primaryTextDark,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      isExpanded: true,
                                      dropdownColor:
                                          AppColor.cardBackgroundDark,
                                      borderRadius: BorderRadius.circular(16),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            _currentCarouselIndex = cities
                                                .indexWhere(
                                                  (city) =>
                                                      city.cityName == newValue,
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
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  margin: const EdgeInsets.only(
                                                    right: 12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        value.cityName ==
                                                            cities[_currentCarouselIndex]
                                                                .cityName
                                                        ? AppColor.primaryBlue
                                                        : AppColor
                                                              .secondaryTextDark
                                                              .withAlpha(128),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    value.cityName,
                                                    style: TextStyle(
                                                      color:
                                                          value.cityName ==
                                                              cities[_currentCarouselIndex]
                                                                  .cityName
                                                          ? AppColor
                                                                .primaryTextDark
                                                          : AppColor
                                                                .secondaryTextDark,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          value.cityName ==
                                                              cities[_currentCarouselIndex]
                                                                  .cityName
                                                          ? FontWeight.w600
                                                          : FontWeight.w400,
                                                    ),
                                                  ),
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Swipeable weather icon with temperature
                        SizedBox(
                          height: 200,
                          child: CarouselSlider.builder(
                            itemCount: cities.length,
                            itemBuilder: (context, index, _) {
                              final city = cities[index];
                              return SizedBox(
                                width: 300,
                                height: 250,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                      bottom: 3,
                                      left: 50,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(51),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.cloud,
                                          size: 140,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 50,
                                      right: 70,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(38),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.cloud,
                                          size: 80,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 20,
                                      left: 40,
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.purple.shade300,
                                              Colors.purple.shade600,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.purple.withAlpha(
                                                77,
                                              ),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            ),
                                            BoxShadow(
                                              color: Colors.white.withAlpha(51),
                                              blurRadius: 2,
                                              offset: const Offset(-2, -2),
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.purple.shade200,
                                                Colors.purple.shade500,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 60,
                                      right: 30,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            city.temperature,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 84,
                                              fontWeight: FontWeight.w100,
                                              letterSpacing: -2,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withAlpha(
                                                    77,
                                                  ),
                                                  blurRadius: 10,
                                                  offset: const Offset(2, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            options: CarouselOptions(
                              height: 200,
                              enlargeCenterPage: true,
                              viewportFraction: 0.9,
                              initialPage: _currentCarouselIndex,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentCarouselIndex = index;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _buildSmartIndicators(cities.length),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cities[_currentCarouselIndex].cityName,
                                style: TextStyle(
                                  color: AppColor.primaryTextDark,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Updated 2 min ago',
                                style: TextStyle(
                                  color: AppColor.secondaryTextDark,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                cities[_currentCarouselIndex].range,
                                style: TextStyle(
                                  color: AppColor.primaryTextDark,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cities[_currentCarouselIndex].description,
                                style: TextStyle(
                                  color: AppColor.secondaryTextDark,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Saturday, July 05, 2025, 07:04 PM WAT',
                                style: TextStyle(
                                  color: AppColor.secondaryTextDark,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColor.cardBackgroundDark.withAlpha(77),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColor.secondaryTextDark.withAlpha(51),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColor.primaryBlue,
                                      AppColor.primaryDarkBlue,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  'Hourly forecast',
                                  style: TextStyle(
                                    color: AppColor.primaryTextDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                'Weekly forecast',
                                style: TextStyle(
                                  color: AppColor.secondaryTextDark,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 0.5,
                          color: AppColor.secondaryTextDark.withAlpha(51),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStat('Humidity', '94%', Icons.water_drop),
                              Container(
                                height: 50,
                                width: 0.5,
                                color: AppColor.secondaryTextDark.withAlpha(77),
                              ),
                              _buildStat('Wind', '7km/h', Icons.air),
                              Container(
                                height: 50,
                                width: 0.5,
                                color: AppColor.secondaryTextDark.withAlpha(77),
                              ),
                              _buildStat(
                                'Precipitation',
                                '30%',
                                Icons.umbrella,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const CircularLoader();
        },
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColor.secondaryTextDark, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: AppColor.primaryTextDark,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: AppColor.secondaryTextDark, fontSize: 12),
        ),
      ],
    );
  }

  List<Widget> _buildSmartIndicators(int itemCount) {
    const int maxVisibleDots = 7;
    const int sideDotsCount = 3;

    List<Widget> indicators = [];

    if (itemCount <= maxVisibleDots) {
      for (int i = 0; i < itemCount; i++) {
        indicators.add(_buildIndicatorDot(i, i == _currentCarouselIndex));
      }
    } else {
      if (_currentCarouselIndex <= sideDotsCount) {
        for (int i = 0; i < maxVisibleDots - 1; i++) {
          indicators.add(_buildIndicatorDot(i, i == _currentCarouselIndex));
        }
        indicators.add(_buildEllipsisDot());
      } else if (_currentCarouselIndex >= itemCount - sideDotsCount - 1) {
        indicators.add(_buildEllipsisDot());
        for (int i = itemCount - (maxVisibleDots - 1); i < itemCount; i++) {
          indicators.add(_buildIndicatorDot(i, i == _currentCarouselIndex));
        }
      } else {
        indicators.add(_buildEllipsisDot());
        for (
          int i = _currentCarouselIndex - 1;
          i <= _currentCarouselIndex + 1;
          i++
        ) {
          indicators.add(_buildIndicatorDot(i, i == _currentCarouselIndex));
        }
        indicators.add(_buildEllipsisDot());
      }
    }

    return indicators;
  }

  Widget _buildIndicatorDot(int index, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 12 : 8,
      height: isActive ? 12 : 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF4A90E2), const Color(0xFF357ABD)],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade600.withAlpha(153),
                  Colors.grey.shade700.withAlpha(102),
                ],
              ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF4A90E2).withAlpha(102),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: const Color(0xFF4A90E2).withAlpha(51),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
    );
  }

  Widget _buildEllipsisDot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade600.withAlpha(77),
      ),
    );
  }
}
