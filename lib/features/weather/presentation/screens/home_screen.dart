import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/core/constants/app_color.dart';
import 'package:weather_app/features/weather/presentation/widgets/circular_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentCarouselIndex = 0;
  String _selectedCity = 'Amsterdam'; // Default selected city

  // List of 15 cities
  final List<String> _cityOptions = [
    'Amsterdam',
    'Lagos',
    'Abuja',
    'Port Harcourt',
    'Kano',
    'Ibadan',
    'Enugu',
    'Kaduna',
    'Jos',
    'Calabar',
    'Owerri',
    'Benin City',
    'Warri',
    'Aba',
    'Onitsha',
  ];

  // Dynamic city data based on selection
  final Map<String, Map<String, String>> _cityData = {
    'Amsterdam': {
      'temp': '17°',
      'range': '16° – 26°',
      'description': 'Partly cloudy',
    },
    'Lagos': {'temp': '28°', 'range': '26° – 32°', 'description': 'Sunny'},
    'Abuja': {'temp': '25°', 'range': '23° – 28°', 'description': 'Cloudy'},
    'Port Harcourt': {
      'temp': '27°',
      'range': '24° – 29°',
      'description': 'Rainy',
    },
    'Kano': {'temp': '30°', 'range': '28° – 34°', 'description': 'Sunny'},
    'Ibadan': {
      'temp': '26°',
      'range': '24° – 30°',
      'description': 'Partly cloudy',
    },
    'Enugu': {'temp': '25°', 'range': '23° – 27°', 'description': 'Cloudy'},
    'Kaduna': {'temp': '29°', 'range': '27° – 33°', 'description': 'Sunny'},
    'Jos': {'temp': '22°', 'range': '20° – 25°', 'description': 'Cool'},
    'Calabar': {'temp': '28°', 'range': '26° – 31°', 'description': 'Humid'},
    'Owerri': {'temp': '26°', 'range': '24° – 28°', 'description': 'Rainy'},
    'Benin City': {
      'temp': '27°',
      'range': '25° – 30°',
      'description': 'Cloudy',
    },
    'Warri': {'temp': '28°', 'range': '26° – 32°', 'description': 'Humid'},
    'Aba': {'temp': '27°', 'range': '25° – 29°', 'description': 'Rainy'},
    'Onitsha': {'temp': '26°', 'range': '24° – 28°', 'description': 'Cloudy'},
  };

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.darkBackground,
      body: SafeArea(
        child: _isLoading
            ? const CircularLoader()
            : FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Main content area
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Beautiful dropdown above temperature - FIXED
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Location label
                                Text(
                                  'Current Location',
                                  style: TextStyle(
                                    color: AppColor.secondaryTextDark,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Custom dropdown container
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.cardBackgroundDark
                                        .withAlpha(102), // 0.4 opacity
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColor.secondaryTextDark
                                          .withAlpha(51), // 0.2 opacity
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      canvasColor: AppColor.cardBackgroundDark,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedCity,
                                        icon: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColor.primaryBlue
                                                .withAlpha(77), // 0.3 opacity
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
                                              _selectedCity = newValue;
                                              _currentCarouselIndex =
                                                  _cityOptions.indexOf(
                                                    newValue,
                                                  );
                                            });
                                          }
                                        },
                                        items: _cityOptions.map<DropdownMenuItem<String>>((
                                          String value,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 6,
                                                    height: 6,
                                                    margin:
                                                        const EdgeInsets.only(
                                                          right: 12,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color:
                                                          value == _selectedCity
                                                          ? AppColor.primaryBlue
                                                          : AppColor
                                                                .secondaryTextDark
                                                                .withAlpha(
                                                                  128,
                                                                ), // 0.5 opacity
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      value,
                                                      style: TextStyle(
                                                        color:
                                                            value ==
                                                                _selectedCity
                                                            ? AppColor
                                                                  .primaryTextDark
                                                            : AppColor
                                                                  .secondaryTextDark,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            value ==
                                                                _selectedCity
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
                          // SWIPEABLE Weather icon with temperature ONLY
                          SizedBox(
                            height: 200,
                            child: CarouselSlider.builder(
                              itemCount: _cityOptions.length,
                              itemBuilder: (context, index, _) {
                                final city = _cityData[_cityOptions[index]]!;
                                return SizedBox(
                                  width: 300,
                                  height: 250,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Main large cloud (bottom layer)
                                      Positioned(
                                        bottom: 3,
                                        left: 50,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.2,
                                                ),
                                                blurRadius: 20,
                                                offset: Offset(0, 10),
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

                                      // Small cloud on top right of the large cloud
                                      Positioned(
                                        bottom: 50,
                                        right: 70,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.15,
                                                ),
                                                blurRadius: 15,
                                                offset: Offset(0, 8),
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

                                      // Moon/sun element with enhanced 3D effect
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
                                                color: Colors.purple.withValues(
                                                  alpha: 0.3,
                                                ),
                                                blurRadius: 20,
                                                offset: Offset(0, 8),
                                              ),
                                              BoxShadow(
                                                color: Colors.white.withValues(
                                                  alpha: 0.2,
                                                ),
                                                blurRadius: 2,
                                                offset: Offset(-2, -2),
                                              ),
                                            ],
                                          ),
                                          child: Container(
                                            margin: EdgeInsets.all(8),
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

                                      // Temperature text with enhanced styling
                                      Positioned(
                                        bottom: 60,
                                        right: 30,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              city['temp']!,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 84,
                                                fontWeight: FontWeight.w100,
                                                letterSpacing: -2,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.3),
                                                    blurRadius: 10,
                                                    offset: Offset(2, 2),
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
                                enlargeCenterPage: false,
                                viewportFraction: 1.0,
                                initialPage: _currentCarouselIndex,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentCarouselIndex = index;
                                    _selectedCity = _cityOptions[index];
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // FIXED Carousel indicators
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildSmartIndicators(),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // FIXED City name and details - left aligned
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _cityOptions[_currentCarouselIndex],
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
                                  _cityData[_cityOptions[_currentCarouselIndex]]!['range']!,
                                  style: TextStyle(
                                    color: AppColor.primaryTextDark,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _cityData[_cityOptions[_currentCarouselIndex]]!['description']!,
                                  style: TextStyle(
                                    color: AppColor.secondaryTextDark,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Thursday, July 03, 2025, 09:35 PM WAT',
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
                    // Bottom section with forecast options and stats
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColor.cardBackgroundDark.withAlpha(
                          77,
                        ), // 0.3 opacity
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColor.secondaryTextDark.withAlpha(
                            51,
                          ), // 0.2 opacity
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Forecast tabs
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
                                    color: AppColor.primaryBlue.withAlpha(
                                      77,
                                    ), // 0.3 opacity
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
                          // Divider
                          Container(
                            height: 0.5,
                            color: AppColor.secondaryTextDark.withAlpha(
                              51,
                            ), // 0.2 opacity
                          ),
                          // Weather stats
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStat('Humidity', '94%', Icons.water_drop),
                                Container(
                                  height: 50,
                                  width: 0.5,
                                  color: AppColor.secondaryTextDark.withAlpha(
                                    77,
                                  ), // 0.3 opacity
                                ),
                                _buildStat('Wind', '7km/h', Icons.air),
                                Container(
                                  height: 50,
                                  width: 0.5,
                                  color: AppColor.secondaryTextDark.withAlpha(
                                    77,
                                  ), // 0.3 opacity
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
              ),
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

  List<Widget> _buildSmartIndicators() {
    const int maxVisibleDots = 7;
    const int sideDotsCount = 3;

    List<Widget> indicators = [];

    if (_cityOptions.length <= maxVisibleDots) {
      // Show all dots if total is less than max
      for (int i = 0; i < _cityOptions.length; i++) {
        indicators.add(_buildIndicatorDot(i, i == _currentCarouselIndex));
      }
    } else {
      // Smart indicator logic
      if (_currentCarouselIndex <= sideDotsCount) {
        // Show first dots + ellipsis
        for (int i = 0; i < maxVisibleDots - 1; i++) {
          indicators.add(_buildIndicatorDot(i, i == _currentCarouselIndex));
        }
        indicators.add(_buildEllipsisDot());
      } else if (_currentCarouselIndex >=
          _cityOptions.length - sideDotsCount - 1) {
        // Show ellipsis + last dots
        indicators.add(_buildEllipsisDot());
        for (
          int i = _cityOptions.length - (maxVisibleDots - 1);
          i < _cityOptions.length;
          i++
        ) {
          indicators.add(_buildIndicatorDot(i, i == _currentCarouselIndex));
        }
      } else {
        // Show ellipsis + middle dots + ellipsis
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
                colors: [
                  const Color(0xFF4A90E2), // Bright blue
                  const Color(0xFF357ABD), // Deeper blue
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade600.withValues(alpha: 0.6),
                  Colors.grey.shade700.withValues(alpha: 0.4),
                ],
              ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF4A90E2).withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: const Color(0xFF4A90E2).withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
        color: Colors.grey.shade600.withValues(alpha: 0.3),
      ),
    );
  }
}
