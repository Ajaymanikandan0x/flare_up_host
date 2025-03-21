abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationUpdated extends LocationState {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String state;
  final String country;

  LocationUpdated({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
  });
}

class LocationError extends LocationState {
  final String message;

  LocationError(this.message);
}
