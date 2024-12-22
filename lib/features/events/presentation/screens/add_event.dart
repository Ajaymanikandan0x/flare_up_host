import 'dart:io';

import 'package:flare_up_host/features/events/domain/entities/event_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/primary_button.dart';
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
import 'approval.dart';

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
  final eventStartTimeController = TextEditingController();
  final eventEndTimeController = TextEditingController();
  final eventRegistrationDeadlineTimeController = TextEditingController();
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
              eventStartTimeController: eventStartTimeController,
              eventStartDateController: eventStartDateController,
              eventEndDateController: eventEndDateController,
              eventRegistrationDeadlineController:
                  eventRegistrationDeadlineController, eventEndTimeController: eventEndTimeController,
                  eventRegistrationDeadlineTimeController: eventRegistrationDeadlineTimeController,
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

    try {
      // Add debug logs
      print('[DEBUG] Image file: $image');
      print('[DEBUG] Banner image URL: $bannerImageUrl');
      
      if (image == null || bannerImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select and upload a banner image')),
        );
        return;
      }

      // Add debug log for event data
      final eventData = EventEntity(
        name: eventNameController.text,
        description: eventDescriptionController.text,
        category: selectedCategoryController.text,
        type: selectedTypeController.text,
        isPaymentRequired: isPaymentRequired,
        ticketPrice: isPaymentRequired ? double.parse(eventTicketPriceController.text) : 0,
        startDateTime: _parseAndFormatDateTime(
          eventStartDateController.text,
          eventStartTimeController.text,
        ) ?? DateTime.now(),
        endDateTime: _parseAndFormatDateTime(
          eventEndDateController.text,
          eventEndTimeController.text,
        ) ?? DateTime.now().add(const Duration(hours: 1)),
        registrationDeadline: _parseAndFormatDateTime(
          eventRegistrationDeadlineController.text,
          eventRegistrationDeadlineTimeController.text,
        ) ?? DateTime.now().add(const Duration(hours: 1)),
   
        
        participantCapacity: int.parse(eventParticipantCapacityController.text),
        latitude: latitude!,
        longitude: longitude!,
        addressLine1: eventAddressLine1Controller.text,
        city: eventCityController.text,
        state: eventStateController.text,
        country: eventCountryController.text,
        hostId: 2, // Using the hostId from logs
        bannerImage: bannerImageUrl,
        promoVideo: promoVideoUrl,
      );
      print('[DEBUG] Event data before bloc: ${eventData.toDebugString()}');
      
      // Add event creation event to bloc
      context.read<EventBloc>().add(CreateEventEvent(eventData, image!, video));

    } catch (e) {
      print('[ERROR] Form submission error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  DateTime? _parseAndFormatDateTime(String date, String time) {
    try {
      if (date.isEmpty) return null;
      
      // Parse date (DD/MM/YYYY format)
      final dateParts = date.split('/');
      if (dateParts.length != 3) return null;
      
      // Parse time (HH:mm format)
      final timeParts = time.isEmpty ? ['00', '00'] : time.split(':');
      if (timeParts.length != 2) return null;

      final dateTime = DateTime(
        int.parse(dateParts[2]), // year
        int.parse(dateParts[1]), // month
        int.parse(dateParts[0]), // day
        int.parse(timeParts[0]), // hour
        int.parse(timeParts[1]), // minute
      );

      return dateTime;
    } catch (e) {
      print('Date parsing error: $e');
      return null;
    }
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
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const EventApprovalWaitingScreen(),
                ),
              );
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
    eventStartTimeController.dispose();
    eventEndTimeController.dispose();
    eventRegistrationDeadlineTimeController.dispose();
    super.dispose();
  }
}
