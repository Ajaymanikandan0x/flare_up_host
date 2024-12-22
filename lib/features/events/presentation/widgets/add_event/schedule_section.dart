import 'package:flutter/material.dart';

import '../../../../../core/widgets/date_field.dart';

class ScheduleSection extends StatelessWidget {
  final TextEditingController eventStartDateController;
  final TextEditingController eventEndDateController;
  final TextEditingController eventRegistrationDeadlineController;

  const ScheduleSection({
    super.key,
    required this.eventStartDateController,
    required this.eventEndDateController,
    required this.eventRegistrationDeadlineController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        DateField(
          controller: eventStartDateController,
          label: 'Event Start Date',
          prefixIcon: const Icon(Icons.calendar_today),
       
        ),
        const SizedBox(height: 16),
        DateField(
          controller: eventEndDateController,
          label: 'Event End Date',
          prefixIcon: const Icon(Icons.calendar_month),
       
        ),
        const SizedBox(height: 16),
        DateField(
          controller: eventRegistrationDeadlineController,
          label: 'Registration Deadline',
          prefixIcon: const Icon(Icons.timer),
    
        ),
      ],
    );
  }
}
