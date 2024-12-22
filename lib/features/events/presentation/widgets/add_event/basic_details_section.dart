import 'package:flutter/material.dart';

import '../../../../../core/widgets/form_field.dart';

class BasicDetailsSection extends StatelessWidget {
  final TextEditingController eventNameController;
  final TextEditingController eventDescriptionController;

  const BasicDetailsSection({
    super.key,
    required this.eventNameController,
    required this.eventDescriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        AppFormField(
          hint: 'Event Name',
          controller: eventNameController,
          icon: const Icon(Icons.event),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter event name';
            }
            if (value.length < 3) {
              return 'Event name must be at least 3 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        AppFormField(
          hint: 'Event Description',
          controller: eventDescriptionController,
          icon: const Icon(Icons.description),
          maxLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter event description';
            }
            if (value.length < 10) {
              return 'Description must be at least 10 characters';
            }
            return null;
          },
        ),
      ],
    );
  }
}
