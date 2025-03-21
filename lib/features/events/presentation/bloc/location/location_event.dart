abstract class LocationEvent {}

class InitializeLocation extends LocationEvent {}

class UpdateLocation extends LocationEvent {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String state;
  final String country;

  UpdateLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
  });
}
