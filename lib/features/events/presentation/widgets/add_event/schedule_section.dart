import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/widgets/date_field.dart';
import '../../../../../core/widgets/time_picker.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../features/events/presentation/bloc/event_bloc.dart';
import '../../../../../features/events/presentation/bloc/event_state.dart';

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

    final DateTime dateTime = DateFormat('yyyy-MM-dd').parse(date);
    final TimeOfDay timeOfDay = TimeOfDay(
      hour: int.parse(time.split(':')[0]),
      minute: int.parse(time.split(':')[1]),
    );

    final DateTime combined = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );

    return DateFormat("yyyy-MM-dd HH:mm:00+05:30").format(combined);
  }

  DateTime? _parseDateTime(String date, String time) {
    if (date.isEmpty || time.isEmpty) return null;
    try {
      final DateTime dateTime = DateFormat('yyyy-MM-dd').parse(date);
      final TimeOfDay timeOfDay = TimeOfDay(
        hour: int.parse(time.split(':')[0]),
        minute: int.parse(time.split(':')[1]),
      );
      return DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
    } catch (e) {
      return null;
    }
  }

  String? _validateDateTime(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please select $fieldName';
    }

    final now = DateTime.now();
    final selected = DateFormat('yyyy-MM-dd').parse(value);

    if (selected.isBefore(now) && !selected.isAtSameMomentAs(now)) {
      return 'Cannot select past dates';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventBloc, EventBlocState>(
      listener: (context, state) {
        if (state is DateSelectionState) {
          final dateFormat = DateFormat('dd/MM/yyyy');

          switch (state.dateType) {
            case 'start':
              if (state.startDate != null) {
                eventStartDateController.text =
                    dateFormat.format(state.startDate!);
              }
              break;
            case 'end':
              if (state.endDate != null) {
                eventEndDateController.text = dateFormat.format(state.endDate!);
              }
              break;
            case 'registration':
              if (state.registrationDeadline != null) {
                eventRegistrationDeadlineController.text =
                    dateFormat.format(state.registrationDeadline!);
              }
              break;
          }
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Schedule Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set your event timeline including registration deadline',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Event Start Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Event Start',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TimeField(
                          controller: eventStartTimeController,
                          label: 'Time',
                          prefixIcon: const Icon(Icons.schedule),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
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
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DateField(
                          controller: eventStartDateController,
                          label: 'Date',
                          dateType: 'start',
                          prefixIcon: const Icon(Icons.calendar_today),
                          validator: (value) =>
                              _validateDateTime(value, 'start date'),
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
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Event End Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Event End',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TimeField(
                          controller: eventEndTimeController,
                          label: 'Time',
                          prefixIcon: const Icon(Icons.schedule),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Required';

                            final startDateTime = _parseDateTime(
                              eventStartDateController.text,
                              eventStartTimeController.text,
                            );
                            final endDateTime = _parseDateTime(
                              eventEndDateController.text,
                              value!,
                            );

                            if (startDateTime != null &&
                                endDateTime != null &&
                                endDateTime.isBefore(startDateTime)) {
                              return 'End time must be after start time';
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
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DateField(
                          controller: eventEndDateController,
                          label: 'Date',
                          dateType: 'end',
                          prefixIcon: const Icon(Icons.calendar_month),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Required';

                            final startDate = DateFormat('yyyy-MM-dd')
                                .parse(eventStartDateController.text);
                            final endDate =
                                DateFormat('yyyy-MM-dd').parse(value!);

                            if (endDate.isBefore(startDate)) {
                              return 'End date must be after start date';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Registration Deadline Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Registration Deadline',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text(
                    'Set when registrations will close',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TimeField(
                          controller: eventRegistrationDeadlineTimeController,
                          label: 'Time',
                          prefixIcon: const Icon(Icons.schedule),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Required';

                            final deadlineDateTime = _parseDateTime(
                              eventRegistrationDeadlineController.text,
                              value!,
                            );
                            final startDateTime = _parseDateTime(
                              eventStartDateController.text,
                              eventStartTimeController.text,
                            );

                            if (deadlineDateTime != null &&
                                startDateTime != null &&
                                !deadlineDateTime.isBefore(startDateTime)) {
                              return 'Deadline must be before event start';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DateField(
                          controller: eventRegistrationDeadlineController,
                          label: 'Date',
                          dateType: 'registration',
                          prefixIcon: const Icon(Icons.timer),
                          validator: (value) =>
                              _validateDateTime(value, 'deadline'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
