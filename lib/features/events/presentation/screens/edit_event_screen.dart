import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/host_event_entite.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';
import '../bloc/location/location_event.dart';
import '../bloc/location/location_bloc.dart';
import '../widgets/add_event/basic_details_section.dart';
import '../widgets/add_event/capacity_section.dart';
import '../widgets/add_event/catagory_section.dart';
import '../widgets/add_event/image_section.dart';
import '../widgets/add_event/location_section.dart';
import '../widgets/add_event/payment_section.dart';
import '../widgets/add_event/schedule_section.dart';
import '../widgets/add_event/video_section.dart';
import '../../../../core/utils/logger.dart';

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({super.key});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late HostEventEntities event;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      // Get event directly from route arguments, handling both possible types
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is HostEventEntities) {
        // Direct model passed
        event = args;
      } else if (args is Map<String, dynamic> && args.containsKey('event')) {
        // Map with event key passed
        event = args['event'] as HostEventEntities;
      } else {
        // Handle error case
        Logger.debug('Invalid arguments passed to EditEventScreen');
        Navigator.pop(context);
        return;
      }

      Logger.debug('Loaded event category: ${event.category}');
      _initialized = true;

      // Initialize controllers after we have the event
      if (!_isControllerInitialized) {
        _initializeControllers();
        _isControllerInitialized = true;
      }
    }

    Responsive.init(context);
  }

  final formKey = GlobalKey<FormState>();
  late int currentStep = 0;
  bool _isControllerInitialized = false;

  // Form controllers
  late TextEditingController eventNameController;
  late TextEditingController eventDescriptionController;
  late TextEditingController eventAddressLine1Controller;
  late TextEditingController eventTicketPriceController;
  late TextEditingController eventParticipantCapacityController;
  late TextEditingController eventStartDateController;
  late TextEditingController eventEndDateController;
  late TextEditingController eventRegistrationDeadlineController;
  late TextEditingController eventCityController;
  late TextEditingController eventStateController;
  late TextEditingController eventCountryController;
  late TextEditingController selectedCategoryController;
  late TextEditingController selectedTypeController;
  late TextEditingController eventStartTimeController;
  late TextEditingController eventEndTimeController;
  late TextEditingController eventRegistrationDeadlineTimeController;

  late bool isPaymentRequired;
  File? imageFile;
  File? videoFile;
  late double latitude;
  late double longitude;

  String? bannerImageUrl;
  String? promoVideoUrl;

  bool _imageAlreadyUploaded = false;
  bool _videoAlreadyUploaded = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    eventNameController = TextEditingController();
    eventDescriptionController = TextEditingController();
    selectedCategoryController = TextEditingController();
    selectedTypeController = TextEditingController();
    // Initialize other controllers...

    // Dispatch event to fetch categories
    Future.delayed(Duration.zero, () {
      // Initialize with categories
      context.read<EventBloc>().add(FetchCategoriesEvent());

      // Use the correct event for setting step
      context.read<EventBloc>().add(EditEventStepChangeEvent(0));

      // Category and type should be set directly to controllers
      selectedCategoryController.text = event.category;
      selectedTypeController.text = event.type;
    });
  }

  void _initializeControllers() {
    // Initialize all controllers first
    eventNameController = TextEditingController(text: event.title);
    eventDescriptionController = TextEditingController(text: event.description);
    eventAddressLine1Controller =
        TextEditingController(text: event.addressLine1);
    eventTicketPriceController =
        TextEditingController(text: event.ticketPrice.toString());
    eventParticipantCapacityController =
        TextEditingController(text: event.participantCapacity.toString());
    eventStartDateController = TextEditingController();
    eventEndDateController = TextEditingController();
    eventRegistrationDeadlineController = TextEditingController();
    eventCityController = TextEditingController(text: event.city);
    eventStateController = TextEditingController(text: event.state);
    eventCountryController = TextEditingController(text: event.country);
    selectedCategoryController = TextEditingController(text: event.category);
    selectedTypeController = TextEditingController(text: event.type);
    eventStartTimeController = TextEditingController();
    eventEndTimeController = TextEditingController();
    eventRegistrationDeadlineTimeController = TextEditingController();

    // Look at the ScheduleSection for the expected format
    // Use DateFormat('dd/MM/yyyy') if that's what the validation expects
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final DateFormat timeFormat = DateFormat('hh:mm a');

    // Now set the text values after all controllers are initialized
    eventStartDateController.text = dateFormat.format(event.startDateTime);
    eventStartTimeController.text = timeFormat.format(event.startDateTime);

    eventEndDateController.text = dateFormat.format(event.endDateTime);
    eventEndTimeController.text = timeFormat.format(event.endDateTime);

    eventRegistrationDeadlineController.text =
        dateFormat.format(event.registrationDeadline);
    eventRegistrationDeadlineTimeController.text =
        timeFormat.format(event.registrationDeadline);

    // Other properties
    isPaymentRequired = event.paymentRequired;
    latitude = event.latitude;
    longitude = event.longitude;

    // URLs for media
    bannerImageUrl = event.bannerImage;
    promoVideoUrl = event.promoVideo;
  }

  DateTime? _parseAndFormatDateTime(String date, String time) {
    if (date.isEmpty) return null;

    try {
      // First, try to ensure date is in correct format (MM/dd/yyyy)
      final DateFormat dateFormat = DateFormat('MM/dd/yyyy');
      DateTime parsedDate;

      try {
        // Try to parse with the expected format first
        parsedDate = dateFormat.parse(date);
      } catch (e) {
        // If that fails, try flexible parsing as a fallback
        parsedDate = DateTime.parse(date);
      }

      // Format the time properly (hh:mm a)
      if (time.isNotEmpty) {
        final List<String> timeParts = time.split(' ');
        final List<String> hourMinute = timeParts[0].split(':');

        int hour = int.parse(hourMinute[0]);
        final int minute = int.parse(hourMinute[1]);

        // Handle AM/PM
        if (timeParts.length > 1) {
          final String amPm = timeParts[1].toUpperCase();
          if (amPm == 'PM' && hour < 12) {
            hour += 12;
          } else if (amPm == 'AM' && hour == 12) {
            hour = 0;
          }
        }

        return DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
          hour,
          minute,
        );
      }

      return parsedDate;
    } catch (e) {
      Logger.error('Error parsing date/time: $date $time', e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventBlocState>(
      listener: (context, state) {
        Logger.debug('🔄 EventBloc state changed: ${state.runtimeType}');

        if (state is EventLoading) {
          // Show loading indicator
          Logger.debug('⏳ Event loading...');
        } else if (state is EventSuccess) {
          Logger.debug('✅ Event update successful! Navigating back...');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event updated successfully')),
          );
          // Navigate back to previous screen
          Navigator.of(context).pop();
        } else if (state is EventError) {
          Logger.debug('❌ Event update error: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Event'),
          elevation: 0,
        ),
        body: BlocConsumer<EventBloc, EventBlocState>(
          listener: (context, state) {
            if (state is EventSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Event updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(
                  context, true); // Return true to indicate successful update
            } else if (state is EventError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is EventImageUploadSuccess) {
              bannerImageUrl = state.url;
            } else if (state is EventVideoUploadSuccess) {
              promoVideoUrl = state.url;
            } else if (state is EditEventStepState) {
              currentStep = state.currentStep;
            } else if (state is PaymentRequiredState) {
              isPaymentRequired = state.isRequired;
            }
          },
          builder: (context, state) {
            final isLoading = state is EventLoading ||
                state is EventMediaUploading ||
                state is EventImageUploadInProgress;

            return Form(
              key: formKey,
              child: Stepper(
                currentStep: currentStep,
                onStepTapped: (step) {
                  context.read<EventBloc>().add(EditEventStepChangeEvent(step));
                },
                onStepContinue: () {
                  final isLastStep = currentStep == 6;
                  if (isLastStep) {
                    _submitForm();
                  } else {
                    context
                        .read<EventBloc>()
                        .add(EditEventStepChangeEvent(currentStep + 1));
                  }
                },
                onStepCancel: () {
                  if (currentStep > 0) {
                    context
                        .read<EventBloc>()
                        .add(EditEventStepChangeEvent(currentStep - 1));
                  }
                },
                steps: [
                  Step(
                    title: const Text('Basic Details'),
                    content: BasicDetailsSection(
                      eventNameController: eventNameController,
                      eventDescriptionController: eventDescriptionController,
                    ),
                    isActive: currentStep >= 0,
                  ),
                  Step(
                    title: const Text('Category'),
                    content: CategorySection(
                      selectedCategory: selectedCategoryController,
                      selectedType: selectedTypeController,
                      categoryError: '',
                      typeError: '',
                    ),
                    isActive: currentStep >= 1,
                  ),
                  Step(
                    title: const Text('Schedule'),
                    content: ScheduleSection(
                      eventStartDateController: eventStartDateController,
                      eventEndDateController: eventEndDateController,
                      eventRegistrationDeadlineController:
                          eventRegistrationDeadlineController,
                      eventStartTimeController: eventStartTimeController,
                      eventEndTimeController: eventEndTimeController,
                      eventRegistrationDeadlineTimeController:
                          eventRegistrationDeadlineTimeController,
                    ),
                    isActive: currentStep >= 2,
                  ),
                  Step(
                    title: const Text('Location'),
                    content: LocationSection(
                      eventAddressLine1Controller: eventAddressLine1Controller,
                      eventCityController: eventCityController,
                      eventStateController: eventStateController,
                      eventCountryController: eventCountryController,
                      onLocationSelected: (lat, lng) {
                        // The simplified callback with just lat and lng
                        context.read<LocationBloc>().add(
                              UpdateLocation(
                                latitude: lat!,
                                longitude: lng!,
                                address: eventAddressLine1Controller.text,
                                city: eventCityController.text,
                                state: eventStateController.text,
                                country: eventCountryController.text,
                              ),
                            );

                        // Update local state variables
                        latitude = lat;
                        longitude = lng!;
                      },
                    ),
                    isActive: currentStep >= 3,
                  ),
                  Step(
                    title: const Text('Capacity'),
                    content: CapacitySection(
                      eventParticipantCapacityController:
                          eventParticipantCapacityController,
                    ),
                    isActive: currentStep >= 4,
                  ),
                  Step(
                    title: const Text('Payment'),
                    content: PaymentSection(
                      isPaymentRequired: isPaymentRequired,
                      eventTicketPriceController: eventTicketPriceController,
                      onPaymentRequiredChanged: (value) {
                        context
                            .read<EventBloc>()
                            .add(TogglePaymentRequiredEvent(value));
                      },
                    ),
                    isActive: currentStep >= 5,
                  ),
                  Step(
                    title: const Text('Media'),
                    content: Column(
                      children: [
                        const SizedBox(height: 16),
                        const Text('Banner Image',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ImageSection(
                          onImageSelected: (media) {
                            if (!_imageAlreadyUploaded) {
                              setState(() {
                                imageFile = media.file;
                                bannerImageUrl = media.url;
                                _imageAlreadyUploaded = true;
                              });
                            }
                          },
                          existingImage: imageFile,
                        ),
                        const SizedBox(height: 24),
                        const Text('Promo Video (Optional)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        VideoSection(
                          onVideoSelected: (media) {
                            if (!_videoAlreadyUploaded) {
                              setState(() {
                                videoFile = media.file;
                                promoVideoUrl = media.url;
                                _videoAlreadyUploaded = true;
                              });
                            }
                          },
                          existingVideo: videoFile,
                          onVideoUploaded: (url) {
                            setState(() {
                              promoVideoUrl = url;
                            });
                          },
                        ),
                      ],
                    ),
                    isActive: currentStep >= 6,
                  ),
                ],
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      children: [
                        if (currentStep > 0)
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Back'),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            onTap: isLoading
                                ? () {}
                                : (details.onStepContinue ?? () {}),
                            text:
                                currentStep == 6 ? 'Update Event' : 'Continue',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // When building dropdown or category selection UI
  Widget buildCategoryDropdown() {
    return BlocBuilder<EventBloc, EventBlocState>(
      builder: (context, state) {
        if (state is CategoriesLoaded) {
          return DropdownButtonFormField<String>(
            value: event.category,
            hint: Text('Select Category'),
            onChanged: (value) {
              // Update category
            },
            items: state.categories.map((category) {
              return DropdownMenuItem(
                value: category.name,
                child: Text(category.name),
              );
            }).toList(),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }

  Future<void> _submitForm() async {
    Logger.debug('🔄 Starting form submission for event update');

    _debugDateFormats(); // Keep this for debugging

    // TEMPORARILY COMMENT THIS OUT to bypass validation
    /*
    if (!formKey.currentState!.validate()) {
      Logger.debug('❌ Form validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
      return;
    }
    */

    try {
      // Use existing URLs if no new files were selected
      final bannerImageUrlToUse =
          imageFile != null ? bannerImageUrl : event.bannerImage;
      final promoVideoUrlToUse =
          videoFile != null ? promoVideoUrl : event.promoVideo;

      // Add more debug logs
      Logger.debug('🚀 Proceeding with form submission');

      // Parse the dates with error handling
      Logger.debug(
          '📅 Parsing start date: ${eventStartDateController.text} ${eventStartTimeController.text}');
      DateTime? startDateTime = _parseAndFormatDateTime(
        eventStartDateController.text,
        eventStartTimeController.text,
      );

      if (startDateTime == null) {
        Logger.debug('❌ Invalid start date format');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid start date format')),
        );
        return;
      }

      Logger.debug(
          '📅 Parsing end date: ${eventEndDateController.text} ${eventEndTimeController.text}');
      DateTime? endDateTime = _parseAndFormatDateTime(
        eventEndDateController.text,
        eventEndTimeController.text,
      );

      if (endDateTime == null) {
        Logger.debug('❌ Invalid end date format');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid end date format')),
        );
        return;
      }

      Logger.debug(
          '📅 Parsing registration deadline: ${eventRegistrationDeadlineController.text} ${eventRegistrationDeadlineTimeController.text}');
      DateTime? registrationDeadline = _parseAndFormatDateTime(
        eventRegistrationDeadlineController.text,
        eventRegistrationDeadlineTimeController.text,
      );

      if (registrationDeadline == null) {
        Logger.debug('❌ Invalid registration deadline format');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid registration deadline format')),
        );
        return;
      }

      // Create updated event entity
      final updatedEvent = EventEntity(
        name: eventNameController.text,
        description: eventDescriptionController.text,
        category: selectedCategoryController.text,
        type: selectedTypeController.text,
        isPaymentRequired: isPaymentRequired,
        ticketPrice: isPaymentRequired
            ? double.parse(eventTicketPriceController.text)
            : 0,
        latitude: latitude,
        longitude: longitude,
        addressLine1: eventAddressLine1Controller.text,
        city: eventCityController.text,
        state: eventStateController.text,
        country: eventCountryController.text,
        participantCapacity: int.parse(eventParticipantCapacityController.text),
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        registrationDeadline: registrationDeadline,
        bannerImage: bannerImageUrlToUse,
        promoVideo: promoVideoUrlToUse,
        hostId: event.hostId,
      );

      Logger.debug('📝 Updated event entity created with:');
      Logger.debug('- Event ID to update: ${event.id}');
      Logger.debug('- Host ID: ${event.hostId}');
      Logger.debug('- Category: ${selectedCategoryController.text}');
      Logger.debug('- Type: ${selectedTypeController.text}');
      Logger.debug('- Start DateTime: $startDateTime');
      Logger.debug('- End DateTime: $endDateTime');
      Logger.debug('- Registration Deadline: $registrationDeadline');

      // Add debug before dispatching the event
      Logger.debug(
          '📤 About to dispatch UpdateEventEvent with ID: ${event.id}');

      // Dispatch the UpdateEventEvent
      context.read<EventBloc>().add(
            UpdateEventEvent(
              eventEntity: updatedEvent,
              eventId: event.id,
              bannerImage: imageFile,
              promoVideo: videoFile,
            ),
          );

      Logger.debug('✅ Event update dispatched successfully!');
    } catch (e) {
      Logger.error('❌ Form submission error:', e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _debugDateFormats() {
    try {
      Logger.debug('🔬 DEBUG: Checking date formats in event form');

      // Log all date-related fields
      Logger.debug('📅 Start date: ${eventStartDateController.text}');
      Logger.debug('🕒 Start time: ${eventStartTimeController.text}');
      Logger.debug('📅 End date: ${eventEndDateController.text}');
      Logger.debug('🕒 End time: ${eventEndTimeController.text}');
      Logger.debug(
          '📅 Registration deadline date: ${eventRegistrationDeadlineController.text}');
      Logger.debug(
          '🕒 Registration deadline time: ${eventRegistrationDeadlineTimeController.text}');

      // Try parsing each date to confirm format
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
      if (eventStartDateController.text.isNotEmpty) {
        final parsed = dateFormat.parse(eventStartDateController.text);
        Logger.debug('✅ Start date parsed successfully: $parsed');
      }
      if (eventEndDateController.text.isNotEmpty) {
        final parsed = dateFormat.parse(eventEndDateController.text);
        Logger.debug('✅ End date parsed successfully: $parsed');
      }
      if (eventRegistrationDeadlineController.text.isNotEmpty) {
        final parsed =
            dateFormat.parse(eventRegistrationDeadlineController.text);
        Logger.debug(
            '✅ Registration deadline date parsed successfully: $parsed');
      }
    } catch (e) {
      Logger.error('❌ Date format debugging error:', e);
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    eventNameController.dispose();
    eventDescriptionController.dispose();
    eventAddressLine1Controller.dispose();
    eventTicketPriceController.dispose();
    eventParticipantCapacityController.dispose();
    eventStartDateController.dispose();
    eventEndDateController.dispose();
    eventRegistrationDeadlineController.dispose();
    eventCityController.dispose();
    eventStateController.dispose();
    eventCountryController.dispose();
    selectedCategoryController.dispose();
    selectedTypeController.dispose();
    eventStartTimeController.dispose();
    eventEndTimeController.dispose();
    eventRegistrationDeadlineTimeController.dispose();
    super.dispose();
  }
}
