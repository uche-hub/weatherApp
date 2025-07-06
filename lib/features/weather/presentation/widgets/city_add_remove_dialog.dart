import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/core/constants/app_color.dart';
import 'package:weather_app/features/weather/presentation/bLoc/weather_bloc.dart';

class CityAddRemoveDialog extends StatelessWidget {
  final List<String> availableCities;
  final List<String> selectedCities;

  const CityAddRemoveDialog({
    super.key,
    required this.availableCities,
    required this.selectedCities,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColor.cardBackgroundDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Manage Cities',
        style: TextStyle(color: AppColor.primaryTextDark),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...availableCities.map(
              (city) => ListTile(
                title: Text(
                  city,
                  style: TextStyle(color: AppColor.primaryTextDark),
                ),
                trailing: selectedCities.contains(city)
                    ? Icon(Icons.check, color: AppColor.successGreen)
                    : IconButton(
                        icon: Icon(Icons.add, color: AppColor.primaryBlue),
                        onPressed: () =>
                            context.read<WeatherBloc>().add(AddCity(city)),
                      ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: TextStyle(color: AppColor.primaryBlue)),
        ),
      ],
    );
  }
}
