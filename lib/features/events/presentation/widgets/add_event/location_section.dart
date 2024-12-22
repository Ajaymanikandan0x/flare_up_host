import 'package:flutter/material.dart';

import '../../../../../core/routes/routs.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../core/widgets/form_field.dart';

class LocationSection extends StatefulWidget {
  final TextEditingController eventAddressLine1Controller;
  final TextEditingController eventCityController;
  final TextEditingController eventStateController;
  final TextEditingController eventCountryController;
  final Function(double?, double?) onLocationSelected;

  const LocationSection({
    super.key,
    required this.eventAddressLine1Controller,
    required this.eventCityController,
    required this.eventStateController,
    required this.eventCountryController,
    required this.onLocationSelected,
  });

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppFormField(
          hint: 'Address Line 1',
          controller: widget.eventAddressLine1Controller,
        ),
        SizedBox(height: Responsive.spacingHeight),
        AppFormField(
          hint: 'City',
          controller: widget.eventCityController,
        ),
        SizedBox(height: Responsive.spacingHeight),
        AppFormField(
          hint: 'State',
          controller: widget.eventStateController,
        ),
        SizedBox(height: Responsive.spacingHeight),
        AppFormField(
          hint: 'Country',
          controller: widget.eventCountryController,
        ),
        SizedBox(height: Responsive.spacingHeight),
        ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.pushNamed(context, AppRouts.location);
            if (result != null && result is Map<String, dynamic>) {
              widget.eventAddressLine1Controller.text = result['street'] ?? '';
              widget.eventCityController.text = result['city'] ?? '';
              widget.eventStateController.text = result['state'] ?? '';
              widget.eventCountryController.text = result['country'] ?? '';
              
              // Update latitude and longitude through callback
              widget.onLocationSelected(
                result['latitude'] as double?,
                result['longitude'] as double?,
              );
            }
          },
          icon: const Icon(Icons.map),
          label: const Text('Select Location on Map'),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, Responsive.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
