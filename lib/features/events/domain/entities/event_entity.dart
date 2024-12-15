class EventEntity {
  final String name;
  final String description;
  final String category;
  final String type;
  final bool isPaymentRequired;
  final double? ticketPrice;
  final double latitude;
  final double longitude;
  final String addressLine1;
  final String city;
  final String state;
  final String country;
  final int participantCapacity;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final DateTime registrationDeadline;
  final String? bannerImage;
  final String? promoVideo;
  final int hostId;

  EventEntity({
    required this.name,
    required this.description,
    required this.category,
    required this.type,
    required this.isPaymentRequired,
    this.ticketPrice,
    required this.latitude,
    required this.longitude,
    required this.addressLine1,
    required this.city,
    required this.state,
    required this.country,
    required this.participantCapacity,
    required this.startDateTime,
    required this.endDateTime,
    required this.registrationDeadline,
    this.bannerImage,
    this.promoVideo,
    required this.hostId,
  });
}
