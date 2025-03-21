import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_picker_google/place_picker_google.dart';

import '../../../../../core/presentation/helpper/snackbar_helper.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../core/widgets/form_field.dart';
import '../../../../../features/events/presentation/bloc/location/location_bloc.dart';
import '../../../../../features/events/presentation/bloc/location/location_state.dart';
import '../../bloc/location/location_event.dart';

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
  final String apiKey = dotenv.env['MAPS_API_KEY'] ?? '';
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    if (apiKey.isEmpty) {
      SnackbarHelper.showError(
        context,
        'API Key is missing. Please check your .env file.',
      );
      return;
    }

    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        SnackbarHelper.showError(
          context,
          'Location permission is required to pick a location',
        );
        return;
      }

      final location = await Geolocator.getCurrentPosition();
      final result = await Navigator.of(context).push<LocationResult>(
        MaterialPageRoute(
          builder: (context) => PlacePicker(
            apiKey: apiKey,
            onPlacePicked: (result) {
              Navigator.of(context).pop(result);
            },
            initialLocation: LatLng(location.latitude, location.longitude),
            usePinPointingSearch: true,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            enableNearbyPlaces: false,
            showSearchInput: true,
            searchInputConfig: SearchInputConfig(
              textDirection: TextDirection.ltr,
              textCapitalization: TextCapitalization.none,
              textAlign: TextAlign.start,
              autofocus: false,
            ),
          ),
        ),
      );

      if (result != null) {
        context.read<LocationBloc>().add(UpdateLocation(
              latitude: result.latLng?.latitude ?? 0.0,
              longitude: result.latLng?.longitude ?? 0.0,
              address: result.formattedAddress ?? '',
              city: result.name ?? '',
              state: result.formattedAddress
                      ?.split(',')
                      .elementAtOrNull(1)
                      ?.trim() ??
                  '',
              country: result.formattedAddress?.split(',').last.trim() ?? '',
            ));
      }
    } catch (e) {
      SnackbarHelper.showError(
        context,
        'Failed to open location picker: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocationBloc, LocationState>(
      listener: (context, state) {
        if (state is LocationUpdated) {
          widget.eventAddressLine1Controller.text = state.address;
          widget.eventCityController.text = state.city;
          widget.eventStateController.text = state.state;
          widget.eventCountryController.text = state.country;
          widget.onLocationSelected(state.latitude, state.longitude);
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: Responsive.spacingHeight),
            if (state is LocationUpdated) _buildMapPreview(state),
            SizedBox(height: Responsive.spacingHeight),
            _buildFormFields(),
            SizedBox(height: Responsive.spacingHeight),
            _buildMapButton(state is LocationLoading),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.location_on, color: AppPalette.gradient2),
        const SizedBox(width: 8),
        const Text(
          'Location Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showLocationInfo(),
          tooltip: 'Location Information',
        ),
      ],
    );
  }

  Widget _buildMapPreview(LocationUpdated state) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppPalette.gradient2.withOpacity(0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(state.latitude, state.longitude),
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('selected_location'),
              position: LatLng(state.latitude, state.longitude),
            ),
          },
          onMapCreated: (controller) => _mapController = controller,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        AppFormField(
          hint: 'Address Line 1',
          controller: widget.eventAddressLine1Controller,
          icon: const Icon(Icons.location_on),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter address' : null,
        ),
        SizedBox(height: Responsive.spacingHeight),
        AppFormField(
          hint: 'City',
          controller: widget.eventCityController,
          icon: const Icon(Icons.location_city),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter city' : null,
        ),
        SizedBox(height: Responsive.spacingHeight),
        AppFormField(
          hint: 'State',
          controller: widget.eventStateController,
          icon: const Icon(Icons.map),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter state' : null,
        ),
        SizedBox(height: Responsive.spacingHeight),
        AppFormField(
          hint: 'Country',
          controller: widget.eventCountryController,
          icon: const Icon(Icons.public),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter country' : null,
        ),
      ],
    );
  }

  Widget _buildMapButton(bool isLoading) {
    return ElevatedButton.icon(
      onPressed: _openLocationPicker,
      icon: const Icon(Icons.map),
      label: Text(isLoading ? 'Loading...' : 'Select Location on Map'),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, Responsive.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showLocationInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Information'),
        content: const Text(
          'You can either manually enter the location details or use the map to pick a location. The map will automatically fill in the address details for you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
