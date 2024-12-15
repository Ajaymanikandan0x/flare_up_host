class CategoryEntity {
  final int id;
  final String name;
  final String description;
  final String status;
  final DateTime updatedAt;
  final List<EventTypeEntity> eventTypes;

  CategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.updatedAt,
    required this.eventTypes,
  });
}

class EventTypeEntity {
  final int id;
  final String name;
  final String description;
  final String status;
  final DateTime updatedAt;

  EventTypeEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.updatedAt,
  });
}
