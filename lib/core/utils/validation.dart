import 'dart:io';
import 'package:intl/intl.dart';

class FormValidator {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 3) {
      return 'Name must be at least 3 characters long';
    }

    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Please enter a valid name';
    }

    return null;
  }

  //Name validateUserName
  static String? validateUserName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 3) {
      return 'Name must be at least 3 characters long';
    }

    return null;
  }

  // Image validation
  static String? validateImage(File? file) {
    if (file == null) {
      return 'Image is required';
    }

    // Check file extension
    final extension = file.path.split('.').last.toLowerCase();
    final validFormats = ['jpg', 'jpeg', 'png', 'gif'];

    if (!validFormats.contains(extension)) {
      return 'Invalid image format. Supported formats: ${validFormats.join(", ")}';
    }

    // Check file size (max 10MB)
    final fileSize = file.lengthSync();
    const maxSize = 10 * 1024 * 1024; // 10MB

    if (fileSize > maxSize) {
      return 'Image size too large. Maximum size: 10MB';
    }

    return null;
  }

  // Video validation
  static String? validateVideo(File? file) {
    if (file == null) {
      return 'Video is required';
    }

    // Check file extension
    final extension = file.path.split('.').last.toLowerCase();
    final validFormats = ['mp4', 'mov', 'avi', 'mkv'];

    if (!validFormats.contains(extension)) {
      return 'Invalid video format. Supported formats: ${validFormats.join(", ")}';
    }

    // Check file size (max 100MB)
    final fileSize = file.lengthSync();
    const maxSize = 100 * 1024 * 1024; // 100MB

    if (fileSize > maxSize) {
      return 'Video size too large. Maximum size: 100MB';
    }

    return null;
  }

  // Time validation
  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time is required';
    }

    // Regular expression for 24-hour time format (HH:MM)
    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');

    if (!timeRegex.hasMatch(value)) {
      return 'Please enter a valid time in HH:MM format';
    }

    return null;
  }

  // Basic date validation
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    try {
      DateFormat('dd/MM/yyyy').parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date in DD/MM/YYYY format';
    }
  }

  // Basic date validation
  static String? validateEventDate(String? value, {bool isStartDate = false}) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    try {
      final date = DateFormat('dd/MM/yyyy').parse(value);
      final now = DateTime.now();

      // Only validate against past dates for start date
      if (isStartDate && date.isBefore(now.subtract(const Duration(days: 1)))) {
        return 'Event cannot start in the past';
      }

      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  // Number validation
  static String? validateNumber(String? value,
      {double? min,
      double? max,
      bool allowDecimal = true,
      String fieldName = 'Number'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    // Check if the value is a valid number
    final number = allowDecimal ? double.tryParse(value) : int.tryParse(value);
    if (number == null) {
      return allowDecimal
          ? 'Please enter a valid number'
          : 'Please enter a valid whole number';
    }

    // Check minimum value if specified
    if (min != null && number < min) {
      return '$fieldName must be at least $min';
    }

    // Check maximum value if specified
    if (max != null && number > max) {
      return '$fieldName must not exceed $max';
    }

    return null;
  }
}
