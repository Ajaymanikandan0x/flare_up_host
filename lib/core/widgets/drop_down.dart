import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class DropDown extends StatelessWidget {
  final GlobalKey dropDownKey;
  final List<String> items;
  final String? selectedItem;
  final String hint;
  final String? errorText;
  final Function(String?)? onChanged;

  const DropDown({
    super.key,
    required this.dropDownKey,
    required this.items,
    this.selectedItem,
    required this.hint,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      key: dropDownKey,
      selectedItem: selectedItem,
      items: (filter, infiniteScrollProps) =>items,
      onChanged: onChanged,
      popupProps: const PopupProps.menu(
        fit: FlexFit.loose,
        constraints: BoxConstraints(),
      ),
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: hint,
          errorText: errorText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
