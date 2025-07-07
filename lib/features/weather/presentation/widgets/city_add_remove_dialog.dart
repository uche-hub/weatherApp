import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/core/constants/app_color.dart';
import 'package:weather_app/features/weather/presentation/bloc/weather_bloc.dart';
import 'package:weather_app/features/weather/presentation/widgets/header_text.dart';
import 'package:weather_app/features/weather/presentation/widgets/description_text.dart';

/// A dialog widget for adding and removing cities from the weather app.
/// Displays available cities to add, and selected cities to remove.
class CityAddRemoveDialog extends StatefulWidget {
  /// List of cities that can be added.
  final List<String> initialAvailableCities;

  /// List of cities that are already selected.
  final List<String> initialSelectedCities;

  /// Callback when a city is selected/added.
  final Function(String)? onCitySelected;

  /// Callback when a city is removed.
  final Function(String)? onCityRemoved;

  const CityAddRemoveDialog({
    super.key,
    required this.initialAvailableCities,
    required this.initialSelectedCities,
    this.onCitySelected,
    this.onCityRemoved,
  });

  @override
  State<CityAddRemoveDialog> createState() => _CityAddRemoveDialogState();
}

class _CityAddRemoveDialogState extends State<CityAddRemoveDialog> {
  /// List of available cities (mutable).
  late List<String> availableCities;

  /// List of selected cities (mutable).
  late List<String> selectedCities;

  /// Initialize local city lists with the initial data.
  @override
  void initState() {
    super.initState();
    availableCities = List.from(widget.initialAvailableCities);
    selectedCities = List.from(widget.initialSelectedCities);
  }

  /// Builds the dialog UI.
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColor.cardBackgroundDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          // Update selected cities if the WeatherLoaded state has new data.
          selectedCities = state is WeatherLoaded
              ? state.cities.map((cw) => cw.cityName ?? 'Unknown').cast<String>().toList()
              : widget.initialSelectedCities;

          // Update available cities by removing already selected ones.
          availableCities = [
            'Lagos', 'Abuja', 'Ibadan', 'Awka', 'Kano', 'Port Harcourt', 'Nneyi-Umuleri',
            'Onitsha', 'Maiduguri', 'Aba', 'Benin City', 'Shagamu', 'Ikare', 'Ogbomoso', 'Mushin'
          ]..removeWhere((city) => selectedCities.contains(city));

          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header title
                HeaderText(
                  text: 'Manage Cities',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColor.primaryTextDark,
                ),
                const SizedBox(height: 20),

                // Section for selected cities
                _buildSection('Selected Cities', selectedCities, true),
                const SizedBox(height: 20),

                // Section for available cities
                _buildSection('Available Cities', availableCities, false),
                const SizedBox(height: 20),

                // Close button
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: DescriptionText(
                      text: 'Close',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primaryTextDark,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds a section for displaying either selected or available cities.
  /// [title]: The section header.
  /// [cities]: The list of cities to display.
  /// [isSelected]: Whether this is the selected cities section (true) or available (false).
  Widget _buildSection(String title, List<String> cities, bool isSelected) {
    context.read<WeatherBloc>(); // Ensure Bloc context is available

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        DescriptionText(
          text: title,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColor.primaryTextDark,
        ),
        const SizedBox(height: 10),

        // Container for the city list
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.primaryTextDark.withAlpha(50)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              return ListTile(
                title: DescriptionText(
                  text: city,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColor.primaryTextDark,
                ),
                trailing: isSelected
                    // Show remove button if city is selected
                    ? IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColor.errorRed),
                        onPressed: widget.onCityRemoved != null ? () => widget.onCityRemoved!(city) : null,
                      )
                    // Show add button if city is available
                    : IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColor.successGreen),
                        onPressed: widget.onCitySelected != null ? () => widget.onCitySelected!(city) : null,
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}
