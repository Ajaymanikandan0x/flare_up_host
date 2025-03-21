import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../../domain/entities/category_entity.dart';
import '../../bloc/event_bloc.dart';
import '../../bloc/event_event.dart';
import '../../bloc/event_state.dart';
import '../../../../../core/utils/logger.dart';

class CategorySection extends StatefulWidget {
  final TextEditingController selectedCategory;
  final TextEditingController selectedType;
  final String? categoryError;
  final String? typeError;

  const CategorySection({
    super.key,
    required this.selectedCategory,
    required this.selectedType,
    required this.categoryError,
    required this.typeError,
  });

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  void _handleCategoryChange(String? value, List<CategoryEntity> categories) {
    if (!mounted) return;

    Logger.debug('=== Category Change Debug ===');
    Logger.debug('Selected Value: $value');

    if (value == null) return;

    // Find the category entity by name
    final selectedCategory = categories.firstWhere(
      (c) => c.name == value,
      orElse: () => CategoryEntity(
        id: 0,
        name: '',
        description: '',
        status: '',
        updatedAt: DateTime.now(),
        eventTypes: [],
      ),
    );

    // Store the ID as a string in the controller
    widget.selectedCategory.text = selectedCategory.id.toString();

    Logger.debug('Selected Category ID: ${selectedCategory.id}');

    // If this category has types, select the first one by default
    if (selectedCategory.eventTypes.isNotEmpty) {
      final defaultType = selectedCategory.eventTypes.first;
      widget.selectedType.text = defaultType.id.toString();
      Logger.debug(
          'Auto-selected default type: ${defaultType.name} (${defaultType.id})');
    } else {
      // Ensure we don't leave type empty - set to 1 if nothing available
      widget.selectedType.text = "1";
      Logger.debug('No types available, setting default type ID: 1');
    }

    context.read<EventBloc>().add(SelectCategoryEvent(
          categoryName: value,
          categories: categories,
          categoryController: widget.selectedCategory,
          typeController: widget.selectedType,
        ));
  }

  void _handleTypeChange(String? value) {
    if (!mounted) return;

    Logger.debug('=== Type Change Debug ===');
    Logger.debug('Selected Value: $value');

    if (value == null || value.isEmpty) {
      Logger.debug('Empty type selected, setting default ID: 1');
      widget.selectedType.text = "1";
      return;
    }

    // Get the current state to access the selected category
    final currentState = context.read<EventBloc>().state;
    if (currentState is CategorySelected) {
      try {
        // Find the category
        final category = currentState.categories.firstWhere(
          (c) => c.name == currentState.categoryName,
        );

        // Find the type by name - with proper type handling
        final eventType = category.eventTypes.firstWhere(
          (t) => t.name == value,
        );

        // Store the ID and ensure it's a valid integer
        final typeId = eventType.id.toString();
        if (int.tryParse(typeId) != null) {
          widget.selectedType.text = typeId;
          Logger.debug('Selected Type ID: $typeId');
        } else {
          Logger.debug('Invalid type ID: $typeId, using default');
          widget.selectedType.text = "1";
        }
      } catch (e) {
        // Handle any exceptions during lookup
        Logger.error('Error finding category or type:', e);
        widget.selectedType.text = "1";
      }
    } else {
      // Default fallback
      Logger.debug('No category state found, using default type ID');
      widget.selectedType.text = "1";
    }

    context.read<EventBloc>().add(SelectTypeEvent(
          typeName: value, // Keep the name for display
          typeController: widget.selectedType,
        ));
  }

  void _validateAndLogSelection() {
    Logger.debug('=== Selection Validation ===');

    // Validate category ID
    if (int.tryParse(widget.selectedCategory.text) == null) {
      Logger.debug('Invalid category ID: ${widget.selectedCategory.text}');
      // Find the first available category with a valid ID
      final state = context.read<EventBloc>().state;
      if (state is CategorySelected || state is CategoriesLoaded) {
        final categories = state is CategorySelected
            ? (state as CategorySelected).categories
            : (state as CategoriesLoaded).categories;

        if (categories.isNotEmpty) {
          widget.selectedCategory.text = categories.first.id.toString();
          Logger.debug('Fixed category ID to: ${widget.selectedCategory.text}');
        }
      }
    }

    // Validate type ID
    if (int.tryParse(widget.selectedType.text) == null) {
      Logger.debug('Invalid type ID: ${widget.selectedType.text}');
      widget.selectedType.text = "1"; // Default fallback
      Logger.debug('Fixed type ID to: 1');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventBlocState>(
      builder: (context, state) {
        Logger.debug(
            'CategorySection Build - Current state: ${state.runtimeType}');

        if (state is CategorySelected) {
          Logger.debug('=== Category State Debug ===');
          Logger.debug('Selected Category: ${state.categoryName}');
          Logger.debug(
              'Available Categories: ${state.categories.map((c) => c.name).join(", ")}');
          Logger.debug('Selected Type: ${state.selectedType}');
          Logger.debug('Available Types: ${state.eventTypes.join(", ")}');
          Logger.debug('Controller Values:');
          Logger.debug(
              '- Category Controller: ${widget.selectedCategory.text}');
          Logger.debug('- Type Controller: ${widget.selectedType.text}');
        }

        if (state is EventLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is EventError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is CategoriesLoaded || state is CategorySelected) {
          List<CategoryEntity> categories = [];
          List<String> eventTypes = [];

          if (state is CategoriesLoaded) {
            categories = state.categories;
            Logger.debug(
                'CategoriesLoaded state with ${categories.length} categories');
          } else if (state is CategorySelected) {
            categories = state.categories;
            eventTypes = state.eventTypes;
            Logger.debug('Available event types: ${eventTypes.join(", ")}');
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Category Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Responsive.spacingHeight),
              DropdownButtonFormField<String>(
                value: state is CategorySelected ? state.categoryName : null,
                decoration: InputDecoration(
                  labelText: 'Select Category',
                  errorText: widget.categoryError,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    Logger.debug('Category dropdown changed to: $value');
                    Logger.debug(
                        'Before event - Category controller: ${widget.selectedCategory.text}');

                    _handleCategoryChange(value, categories);

                    Logger.debug(
                        'After event - Category controller: ${widget.selectedCategory.text}');
                  }
                },
              ),
              if (eventTypes.isNotEmpty) ...[
                SizedBox(height: Responsive.spacingHeight),
                DropdownButtonFormField<String>(
                  value: state is CategorySelected ? state.selectedType : null,
                  decoration: InputDecoration(
                    labelText: 'Select Event Type',
                    errorText: widget.typeError,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.type_specimen),
                  ),
                  items: eventTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      Logger.debug('Type dropdown changed to: $value');
                      Logger.debug(
                          'Before event - Type controller: ${widget.selectedType.text}');

                      _handleTypeChange(value);

                      Logger.debug(
                          'After event - Type controller: ${widget.selectedType.text}');
                    }
                  },
                ),
              ],
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
