import 'package:flare_up_host/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_palette.dart';
import '../theme/text_theme.dart';

class DateField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final Widget? prefixIcon;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  const DateField({
    super.key,
    required this.controller,
    this.label,
    this.prefixIcon,
    this.onChanged,
    this.validator,
  });

  @override
  _DateFieldState createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      style: AppTextStyles.primaryTextTheme(),
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: 'DD/MM/YYYY',
        prefixIcon: widget.prefixIcon,
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: theme.brightness == Brightness.dark
                ? AppPalette.darkDivider
                : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppPalette.gradient2, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 23,
          horizontal: 23,
        ),
      ),
      validator: (value) {
        // First check the custom validator if provided
        if (widget.validator != null) {
          final customValidation = widget.validator!(value);
          if (customValidation != null) {
            return customValidation;
          }
        }

        // Required field validation
        if (value == null || value.isEmpty) {
          return 'Please select a date';
        }

        try {
          final selectedDate = DateFormat('dd/MM/yyyy').parse(value);
          final now = DateTime.now();

          // Strip time component for accurate date comparison
          final today = DateTime(now.year, now.month, now.day);
          final selected =
              DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

          // Add additional date validations
          if (selected.isBefore(today)) {
            return 'Date cannot be in the past';
          }

          // Use responsive max date based on screen size
          final maxYears = Responsive.isTablet
              ? 50
              : 25;
          final maxDate = today.add(Duration(days: 365 * maxYears));
          if (selected.isAfter(maxDate)) {
            return 'Date cannot be more than $maxYears years in the future';
          }

          // Validate date format matches exactly DD/MM/YYYY
          if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
            return 'Please use DD/MM/YYYY format';
          }

          return null;
        } catch (e) {
          return 'Please enter a valid date';
        }
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        widget.controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
      widget.onChanged?.call(widget.controller.text);
    }
  }
}

class PrimaryContainer extends StatelessWidget {
  final Widget child;
  final double? radius;
  final Color? color;
  const PrimaryContainer({
    super.key,
    this.radius,
    this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 30),
        boxShadow: [
          BoxShadow(
            color: color ?? const Color(0XFF1E1E1E),
          ),
          const BoxShadow(
            offset: Offset(2, 2),
            blurRadius: 4,
            spreadRadius: 0,
            color: Colors.black,
          ),
        ],
      ),
      child: child,
    );
  }
}
