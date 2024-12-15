import '../../domain/entities/event_entity.dart';

class EventModel extends EventEntity {
  EventModel({
    required super.name,
    required super.description,
    required super.category,
    required super.type,
    required super.isPaymentRequired,
    super.ticketPrice,
    required super.latitude,
    required super.longitude,
    required super.addressLine1,
    required super.city,
    required super.state,
    required super.country,
    required super.participantCapacity,
    required super.startDateTime,
    required super.endDateTime,
    required super.registrationDeadline,
    super.bannerImage,
    super.promoVideo,
    required super.hostId,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      name: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      type: json['type'] ?? '',
      isPaymentRequired: json['payment_required'] ?? false,
      ticketPrice: json['ticket_price']?.toDouble(),
      latitude: json['latitude'] ?? 0,
      longitude: json['longitude'] ?? 0,
      addressLine1: json['address_line_1'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      participantCapacity: json['participant_capacity'] ?? 0,
      startDateTime: DateTime.parse(
          json['start_date_time'] ?? DateTime.now().toIso8601String()),
      endDateTime: DateTime.parse(
          json['end_date_time'] ?? DateTime.now().toIso8601String()),
      registrationDeadline: DateTime.parse(
          json['registration_deadline'] ?? DateTime.now().toIso8601String()),
      bannerImage: json['banner_image'],
      promoVideo: json['promo_video'],
      hostId: json['host_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'type': type,
      'is_payment_required': isPaymentRequired,
      'ticket_price': ticketPrice,
      'latitude': latitude,
      'longitude': longitude,
      'address_line_1': addressLine1,
      'city': city,
      'state': state,
      'country': country,
      'participant_capacity': participantCapacity,
      'start_date_time': startDateTime.toIso8601String(),
      'end_date_time': endDateTime.toIso8601String(),
      'registration_deadline': registrationDeadline.toIso8601String(),
      'banner_image': bannerImage,
      'promo_video': promoVideo,
      'host_id': hostId,
    };
  }

  EventEntity toEntity() {
    return EventEntity(
      name: name,
      description: description,
      category: category,
      type: type,
      isPaymentRequired: isPaymentRequired,
      ticketPrice: ticketPrice,
      latitude: latitude,
      longitude: longitude,
      addressLine1: addressLine1,
      city: city,
      state: state,
      country: country,
      participantCapacity: participantCapacity,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      registrationDeadline: registrationDeadline,
      bannerImage: bannerImage,
      promoVideo: promoVideo,
      hostId: hostId,
    );
  }
}
