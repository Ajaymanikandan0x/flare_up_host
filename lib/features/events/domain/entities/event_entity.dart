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

  EventEntity copyWith({
    String? name,
    String? description,
    String? category,
    String? type,
    bool? isPaymentRequired,
    double? ticketPrice,
    double? latitude,
    double? longitude,
    String? addressLine1,
    String? city,
    String? state,
    String? country,
    int? participantCapacity,
    DateTime? startDateTime,
    DateTime? endDateTime,
    DateTime? registrationDeadline,
    String? bannerImage,
    String? promoVideo,
    int? hostId,
  }) {
    return EventEntity(
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      isPaymentRequired: isPaymentRequired ?? this.isPaymentRequired,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressLine1: addressLine1 ?? this.addressLine1,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      participantCapacity: participantCapacity ?? this.participantCapacity,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      bannerImage: bannerImage ?? this.bannerImage,
      promoVideo: promoVideo ?? this.promoVideo,
      hostId: hostId ?? this.hostId,
    );
  }

  String toDebugString() {
    return '''
      EventEntity {
        name: $name,
        category: $category,
        type: $type,
        bannerImage: $bannerImage,
        promoVideo: $promoVideo,
        hostId: $hostId
      }
    ''';
  }
}
