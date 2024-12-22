import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flare_up_host/core/routes/routs.dart';
import 'package:flare_up_host/core/utils/file_picker_service.dart';
import 'package:flare_up_host/core/utils/image_picker_service.dart';
import 'package:flare_up_host/core/widgets/drop_down.dart';
import 'package:flare_up_host/core/widgets/time_picker.dart';
import 'package:flare_up_host/features/events/domain/entities/event_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/date_field.dart';
import '../../../../core/widgets/form_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/toggle.dart';
import '../../../../core/widgets/video_player.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';
import '../widgets/add_event/basic_details_section.dart';
import '../widgets/add_event/capacity_section.dart';
import '../widgets/add_event/catagory_section.dart';
import '../widgets/add_event/image_section.dart';
import '../widgets/add_event/location_section.dart';
import '../widgets/add_event/payment_section.dart';
import '../widgets/add_event/schedule_section.dart';
import '../widgets/add_event/video_section.dart';
import '../widgets/image_card.dart';
import '../../../../core/storage/secure_storage_service.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Responsive.init(context);
  }

  final formKey = GlobalKey<FormState>();
  int currentStep = 0;

  // Your existing controllers
  final eventNameController = TextEditingController();
  final eventDescriptionController = TextEditingController();
  final eventAddressLine1Controller = TextEditingController();
  final eventTicketPriceController = TextEditingController();
  final eventParticipantCapacityController = TextEditingController();
  final eventStartDateController = TextEditingController();
  final eventEndDateController = TextEditingController();
  final eventRegistrationDeadlineController = TextEditingController();
  final eventCityController = TextEditingController();
  final eventStateController = TextEditingController();
  final eventCountryController = TextEditingController();
  final selectedCategoryController = TextEditingController();
  final selectedTypeController = TextEditingController();
  bool isPaymentRequired = false;
  File? image;
  File? video;
  double? latitude;
  double? longitude;

  String? selectedCategory;
  String? selectedType;
  String? categoryError;
  String? typeError;

  String? bannerImageUrl;
  String? promoVideoUrl;

  @override
  void initState() {
    super.initState();
    context.read<EventBloc>().add(FetchCategoriesEvent());
  }

  List<Step> getSteps() {
    return [
      Step(
        title: const Text('Basic Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BasicDetailsSection(
              eventNameController: eventNameController,
              eventDescriptionController: eventDescriptionController,
            ),
            SizedBox(height: Responsive.spacingHeight * 2),
            CategorySection(
              selectedCategory: selectedCategoryController,
              selectedType: selectedTypeController,
              categoryError: categoryError,
              typeError: typeError,
            ),
            SizedBox(height: Responsive.spacingHeight * 2),
            PaymentSection(
              isPaymentRequired: isPaymentRequired,
              eventTicketPriceController: eventTicketPriceController,
              onPaymentRequiredChanged: (bool value) {
                setState(() {
                  isPaymentRequired = value;
                });
              },
            ),
          ],
        ),
        isActive: currentStep >= 0,
      ),
      Step(
        title: const Text('Schedule & Capacity'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScheduleSection(
              eventStartDateController: eventStartDateController,
              eventEndDateController: eventEndDateController,
              eventRegistrationDeadlineController:
                  eventRegistrationDeadlineController,
            ),
            SizedBox(height: Responsive.spacingHeight * 2),
            CapacitySection(
              eventParticipantCapacityController:
                  eventParticipantCapacityController,
            ),
          ],
        ),
        isActive: currentStep >= 1,
      ),
      Step(
        title: const Text('Location'),
        content: Column(
          children: [
            LocationSection(
              eventAddressLine1Controller: eventAddressLine1Controller,
              eventCityController: eventCityController,
              eventStateController: eventStateController,
              eventCountryController: eventCountryController,
              onLocationSelected: (lat, lng) {
                setState(() {
                  latitude = lat;
                  longitude = lng;
                });
              },
            ),
          ],
        ),
        isActive: currentStep >= 2,
      ),
      Step(
        title: const Text('Media'),
        content: Column(
          children: [
            ImageSection(
              existingImage: image,
              onImageSelected: (media) {
                setState(() {
                  image = media.file;
                  bannerImageUrl = media.url;
                });
              },
            ),
            SizedBox(height: Responsive.spacingHeight),
            VideoSection(
              existingVideo: video,
              onVideoSelected: (media) {
                setState(() {
                  video = media.file;
                  promoVideoUrl = media.url;
                });
              },
            ),
          ],
        ),
        isActive: currentStep >= 4,
      ),
    ];
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          getSteps().length,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 70,
            height: 4,
            decoration: BoxDecoration(
              color: currentStep >= index
                  ? AppPalette.gradient2
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Basic Details';
      case 1:
        return 'Schedule & Capacity';
      case 2:
        return 'Location Details';
      case 3:
        return 'Media Upload';
      default:
        return '';
    }
  }

  void _handleFormSubmission() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Get the current hoster ID
    final hosterId = await context.read<SecureStorageService>().getUserId();

    if (hosterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found')),
      );
      return;
    }

    // Validate all required fields
    if (selectedCategory == null) {
      setState(() => categoryError = 'Please select a category');
      return;
    }
    if (selectedType == null) {
      setState(() => typeError = 'Please select an event type');
      return;
    }
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a banner image')),
      );
      return;
    }

    // Validate dates
    try {
      final startDate = DateTime.parse(eventStartDateController.text);
      final endDate = DateTime.parse(eventEndDateController.text);
      final registrationDeadline =
          DateTime.parse(eventRegistrationDeadlineController.text);

      if (endDate.isBefore(startDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End date cannot be before start date')),
        );
        return;
      }
      if (registrationDeadline.isAfter(startDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Registration deadline must be before event start')),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid dates')),
      );
      return;
    }

    final eventData = EventEntity(
      name: eventNameController.text,
      description: eventDescriptionController.text,
      category: selectedCategory!,
      type: selectedType!,
      isPaymentRequired: isPaymentRequired,
      ticketPrice:
          isPaymentRequired ? double.parse(eventTicketPriceController.text) : 0,
      startDateTime: DateTime.parse(eventStartDateController.text),
      endDateTime: DateTime.parse(eventEndDateController.text),
      registrationDeadline:
          DateTime.parse(eventRegistrationDeadlineController.text),
      participantCapacity: int.parse(eventParticipantCapacityController.text),
      latitude: latitude!,
      longitude: longitude!,
      addressLine1: eventAddressLine1Controller.text,
      city: eventCityController.text,
      state: eventStateController.text,
      country: eventCountryController.text,
      hostId: int.parse(hosterId),
      bannerImage: bannerImageUrl,
      promoVideo: promoVideoUrl,
    );

    context.read<EventBloc>().add(
          CreateEventEvent(
            eventData,
            image!,
            video,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          setState(() {
            currentStep--;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (currentStep > 0) {
                setState(() {
                  currentStep--;
                });
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(_getStepTitle(currentStep)),
        ),
        body: BlocListener<EventBloc, EventBlocState>(
          listener: (context, state) {
            if (state is EventError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is EventSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Event created successfully')),
              );
              Navigator.of(context).pop();
            }
          },
          child: Form(
            key: formKey,
            child: Column(
              children: [
                _buildStepIndicator(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.horizontalPadding,
                    ),
                    child: getSteps()[currentStep].content,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(Responsive.horizontalPadding),
                  child: PrimaryButton(
                    onTap: () {
                      final isLastStep = currentStep == getSteps().length - 1;
                      if (isLastStep) {
                        _handleFormSubmission();
                      } else {
                        setState(() {
                          currentStep += 1;
                        });
                      }
                    },
                    text: currentStep == getSteps().length - 1
                        ? 'Create Event'
                        : 'Next',
                    width: double.infinity,
                    height: Responsive.buttonHeight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
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
    super.dispose();
  }
}
