import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_palette.dart';
import '../theme/text_theme.dart';

class DateField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final Widget? prefixIcon;
  final Function(String)? onChanged;
  const DateField({
    super.key, 
    required this.controller, 
    this.label, 
    this.prefixIcon, 
    this.onChanged,
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
        if (value == null || value.isEmpty) {
          return 'Please select a date';
        }
        
        try {
          final selectedDate = DateFormat('dd/MM/yyyy').parse(value);
          final now = DateTime.now();
          
          if (selectedDate.isBefore(now)) {
            return 'Date cannot be in the past';
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
