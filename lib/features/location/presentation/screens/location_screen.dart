import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

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

  // Places API variables
  final _uuid = const Uuid();
  String _sessionToken = '1234567890';
  List<dynamic> _placeList = [];
  final Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_sessionToken.isEmpty) {
      setState(() {
        _sessionToken = _uuid.v4();
      });
    }
    _getSuggestions(_searchController.text);
  }

  Future<void> _getSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _placeList = [];
      });
      return;
    }

    final String? placesApiKey = 'AIzaSyA_2QMkoy2q7hjzTJp_8OVjkwI6-Gqdtsg';
    // await SecureStorageService().getGoogleMapsApiKey();

    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$placesApiKey&sessiontoken=$_sessionToken';

      var response = await dio.get(request);
      var data = response.data;

      if (response.statusCode == 200) {
        setState(() {
          _placeList = data['predictions'];
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching place suggestions: $e');
      }
    }
  }

  Future<void> _selectPlace(String placeId) async {
    final String? placesApiKey = 'AIzaSyA_2QMkoy2q7hjzTJp_8OVjkwI6-Gqdtsg';
    // await SecureStorageService().getGoogleMapsApiKey();

    try {
      String detailsURL =
          'https://maps.googleapis.com/maps/api/place/details/json';
      String request = '$detailsURL?place_id=$placeId&key=$placesApiKey';

      var response = await dio.get(request);
      var data = response.data;

      if (response.statusCode == 200) {
        var location = data['result']['geometry']['location'];
        final LatLng selectedPosition =
            LatLng(location['lat'], location['lng']);

        // Clear previous search list
        setState(() {
          _placeList = [];
          _searchController.clear();
        });

        // Add marker and move camera
        await _addMarker(selectedPosition);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching place details: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            mapType: MapType.normal,
            initialCameraPosition:
                CameraPosition(target: _initialPosition, zoom: 12),
            markers: _markers,
            onTap: _addMarker,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search location',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _placeList = [];
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                if (_placeList.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _placeList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_placeList[index]['description']),
                          onTap: () {
                            _selectPlace(_placeList[index]['place_id']);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          // Existing zoom buttons
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "zoomIn",
                  mini: true,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "zoomOut",
                  mini: true,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place.name ?? 'Selected Location',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${place.street}, ${place.locality}'),
            Text('${place.administrativeArea}, ${place.country}'),
            Text('Postal Code: ${place.postalCode}'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.add_location),
              label: const Text('Select Location'),
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
}
