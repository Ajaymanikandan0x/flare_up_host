import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({
    required super.id,
    required super.name,
    required super.description,
    required super.status,
    required super.updatedAt,
    required List<EventTypeModel> super.eventTypes,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
      updatedAt: DateTime.parse(json['updated_at']),
      eventTypes: (json['event_types'] as List)
          .map((item) => EventTypeModel.fromJson(item))
          .toList(),
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      description: description,
      status: status,
      updatedAt: updatedAt,
      eventTypes: eventTypes,
    );
  }
}

class EventTypeModel extends EventTypeEntity {
  EventTypeModel({
    required super.id,
    required super.name,
    required super.description,
    required super.status,
    required super.updatedAt,
  });

  factory EventTypeModel.fromJson(Map<String, dynamic> json) {
    return EventTypeModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
