import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/widgets/date_field.dart';
import '../../../../../core/widgets/time_picker.dart';

class ScheduleSection extends StatelessWidget {
  final TextEditingController eventStartDateController;
  final TextEditingController eventEndDateController;
  final TextEditingController eventRegistrationDeadlineController;
  final TextEditingController eventStartTimeController;
  final TextEditingController eventEndTimeController;
  final TextEditingController eventRegistrationDeadlineTimeController;
  const ScheduleSection({
    super.key,
    required this.eventStartTimeController,
    required this.eventEndTimeController,
    required this.eventStartDateController,
    required this.eventEndDateController,
    required this.eventRegistrationDeadlineController,
    required this.eventRegistrationDeadlineTimeController,
  });

  String _combineDateAndTime(String date, String time) {
    if (date.isEmpty || time.isEmpty) return '';

    // Parse the date and time
    final DateTime dateTime = DateFormat('yyyy-MM-dd').parse(date);
    final TimeOfDay timeOfDay = TimeOfDay(
      hour: int.parse(time.split(':')[0]),
      minute: int.parse(time.split(':')[1]),
    );

    // Combine date and time
    final DateTime combined = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );

    // Format to match database format
    return DateFormat("yyyy-MM-dd HH:mm:00+05:30").format(combined);
  }

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
        TimeField(
          controller: eventStartTimeController,
          label: 'Event Start Time',
          prefixIcon: const Icon(Icons.schedule),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select start time';
            }
            return null;
          },
          onChanged: (time) {
            if (eventStartDateController.text.isNotEmpty) {
              final formattedDateTime = _combineDateAndTime(
                eventStartDateController.text,
                time,
              );
              eventStartDateController.text = formattedDateTime;
            }
          },
        ),
        const SizedBox(height: 16),
        DateField(
          controller: eventStartDateController,
          label: 'Event Start Date',
          prefixIcon: const Icon(Icons.calendar_today),
          onChanged: (date) {
            if (eventStartTimeController.text.isNotEmpty) {
              final formattedDateTime = _combineDateAndTime(
                date,
                eventStartTimeController.text,
              );
              eventStartDateController.text = formattedDateTime;
            }
          },
        ),
        const SizedBox(height: 16),
        DateField(
          controller: eventEndDateController,
          label: 'Event End Date',
          prefixIcon: const Icon(Icons.calendar_month),
        ),
        const SizedBox(height: 16),
        TimeField(
          controller: eventEndTimeController,
          label: 'Event End Time',
          prefixIcon: const Icon(Icons.schedule),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select end time';
            }
            return null;
          },
          onChanged: (time) {
            if (eventEndDateController.text.isNotEmpty) {
              final formattedDateTime = _combineDateAndTime(
                eventEndDateController.text,
                time,
              );
              eventEndDateController.text = formattedDateTime;
            }
          },
        ),
        const SizedBox(height: 16),
        DateField(
          controller: eventRegistrationDeadlineController,
          label: 'Registration Deadline',
          prefixIcon: const Icon(Icons.timer),
        ),
        const SizedBox(height: 16),
        TimeField(
          controller: eventRegistrationDeadlineTimeController,
          label: 'Registration Deadline Time',
          prefixIcon: const Icon(Icons.schedule),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select registration deadline time';
            }
            return null;
          },
        ),
      ],
    );
  }
}
