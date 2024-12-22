import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class DropDown extends StatelessWidget {
  final GlobalKey<DropdownSearchState> dropDownKey;
  final List<String> items;
  final String? selectedItem;
  final String hint;
  final String? errorText;
  final Widget? prefixIcon;
  final Function(String?) onChanged;

  const DropDown({
    required this.dropDownKey,
    required this.items,
    required this.selectedItem,
    required this.hint,
    required this.onChanged,
    this.errorText,
    this.prefixIcon,
    super.key,
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
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }
}
