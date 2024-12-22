import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../core/widgets/drop_down.dart';
import '../../bloc/event_bloc.dart';
import '../../bloc/event_state.dart';

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
  final _categoryKey = GlobalKey<DropdownSearchState>();
  final _typeKey = GlobalKey<DropdownSearchState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventBlocState>(
      builder: (context, state) {
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
        
        if (state is CategoriesLoaded) {
          if (state.categories.isEmpty) {
            return const Center(
              child: Text('No categories available'),
            );
          }

          final categories = state.categories.map((c) => c.name).toList();
          final eventTypes = state.eventTypes;

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
              DropDown(
                dropDownKey: _categoryKey,
                items: categories,
                selectedItem: widget.selectedCategory.text,
                hint: 'Select Category',
                errorText: widget.categoryError,
                prefixIcon: const Icon(Icons.category),
                onChanged: (value) {
                  if (!mounted) return;
                  widget.selectedCategory.text = value ?? '';
                },
              ),
              SizedBox(height: Responsive.spacingHeight),
              DropDown(
                dropDownKey: _typeKey,
                items: eventTypes,
                selectedItem: widget.selectedType.text,
                hint: 'Select Event Type',
                errorText: widget.typeError,
                prefixIcon: const Icon(Icons.type_specimen),
                onChanged: (value) {
                  if (!mounted) return;
                  widget.selectedType.text = value ?? '';
                },
              ),
            ],
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  @override
  void dispose() {
    // Close dropdowns before disposing
    _categoryKey.currentState?.closeDropDownSearch();
    _typeKey.currentState?.closeDropDownSearch();
    super.dispose();
  }
}
