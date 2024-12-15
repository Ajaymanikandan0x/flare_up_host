import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/text_theme.dart';


class AppFormField extends StatelessWidget {
  final Icon? icon;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final TextInputType? keyboardType;
  final int? maxLines;

  const AppFormField({
    super.key,
    required this.hint,
    this.icon,
    required this.controller,
    this.validator,
    this.textInputAction,
    this.autofocus = false,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextFormField(
      style: AppTextStyles.primaryTextTheme(),
      controller: controller,
      validator: validator,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,

      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: hint,
        hintText: hint,
        prefixIcon: icon != null 
          ? Icon(
              icon!.icon,
              color: theme.brightness == Brightness.dark
                  ? AppPalette.darkHint
                  : AppPalette.lightHint,
            )
          : null,
        filled: true,
        fillColor: theme.cardColor,
        border: InputBorder.none,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppPalette.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppPalette.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 23,
          horizontal: 23,
        ),
      ),
    );
  }
}