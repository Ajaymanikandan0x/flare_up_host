import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flare_up_host/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();

  final LatLng _initialPosition = const LatLng(37.77483, -122.41942);
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final hasPermission = await _requestLocationPermission();
    if (hasPermission) {
      _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Select Location',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppPalette.darkHint
                : AppPalette.lightHint,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            mapType: _currentMapType,
            initialCameraPosition:
                CameraPosition(target: _initialPosition, zoom: 12),
            markers: _markers,
            onTap: _addMarker,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search location',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
                onSubmitted: (value) => _searchPlace(value),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "locate",
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppPalette.darkCard
                          : AppPalette.lightCard,
                  child: Icon(
                    Icons.my_location,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppPalette.darkText
                        : AppPalette.lightText,
                  ),
                  onPressed: _getCurrentLocation,
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "layers",
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppPalette.darkCard
                          : AppPalette.lightCard,
                  child: Icon(
                    Icons.layers,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppPalette.darkText
                        : AppPalette.lightText,
                  ),
                  onPressed: _onMapTypeButtonPressed,
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoom",
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppPalette.darkCard
                          : AppPalette.lightCard,
                  child: Icon(
                    Icons.zoom_in,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppPalette.darkText
                        : AppPalette.lightText,
                  ),
                  onPressed: _zoomIn,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location services are disabled. Please enable them in settings.'),
          ),
        );
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are denied.'),
            ),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location permissions are permanently denied. Please enable them in settings.'),
          ),
        );
      }
      return false;
    }

    return true;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _addMarker(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.first;
      final address = '${place.street}, ${place.locality}, ${place.country}';

      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('selected'),
            position: position,
            infoWindow: InfoWindow(
              title: place.name ?? 'Selected Location',
              snippet: address,
              onTap: () => _showLocationDetails(place),
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      });

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(target: position, zoom: 15)),
      );
    } catch (e) {
      debugPrint('Error getting location details: $e');
    }
  }

  void _showLocationDetails(Placemark place) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place.name ?? 'Selected Location',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${place.street}, ${place.locality}',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, {
                    'street': place.street,
                    'city': place.locality,
                    'state': place.administrativeArea,
                    'country': place.country,
                    'latitude': _markers.first.position.latitude,
                    'longitude': _markers.first.position.longitude,
                  });
                },
                child: const Text(
                  'Select This Location',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _zoomIn() async =>
      mapController.animateCamera(CameraUpdate.zoomIn());

  Future<void> _zoomOut() async =>
      mapController.animateCamera(CameraUpdate.zoomOut());

  void _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final LatLng currentPosition = LatLng(
        position.latitude,
        position.longitude,
      );

      await _addMarker(currentPosition);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Failed to get current location. Please check your location settings.'),
          ),
        );
      }
    }
  }

  void _onMapTypeButtonPressed() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.map),
                title: Text('Normal'),
                onTap: () {
                  setState(() {
                    _currentMapType = MapType.normal;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.satellite),
                title: Text('Satellite'),
                onTap: () {
                  setState(() {
                    _currentMapType = MapType.satellite;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.terrain),
                title: Text('Terrain'),
                onTap: () {
                  setState(() {
                    _currentMapType = MapType.terrain;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _searchPlace(String input) async {
    if (input.isEmpty) return;

    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/findplacefromtext/json';
      String request =
          '$baseURL?input=$input&inputtype=textquery&fields=geometry,formatted_address,place_id&key=AIzaSyA_2QMkoy2q7hjzTJp_8OVjkwI6-Gqdtsg';

      final dio = Dio();
      var response = await dio.get(request);
      var data = response.data;

      if (response.statusCode == 200 && data['candidates'].isNotEmpty) {
        var location = data['candidates'][0]['geometry']['location'];
        final LatLng selectedPosition =
            LatLng(location['lat'], location['lng']);

        // Clear search text
        _searchController.clear();

        // Add marker and move camera
        await _addMarker(selectedPosition);

        // Animate camera to the selected location
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: selectedPosition,
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error searching place: $e');
    }
  }
}
