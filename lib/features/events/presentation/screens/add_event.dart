import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flare_up_host/core/utils/file_picker_service.dart';
import 'package:flare_up_host/core/utils/image_picker_service.dart';
import 'package:flare_up_host/core/widgets/drop_down.dart';
import 'package:flare_up_host/core/widgets/time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/date_field.dart';
import '../../../../core/widgets/form_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/toggle.dart';
import '../../../../core/widgets/video_player.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';
import '../widgets/image_card.dart';
import '../bloc/event_bloc.dart';

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
  final eventLocationController = TextEditingController();
  final eventTicketPriceController = TextEditingController();
  final eventParticipantCapacityController = TextEditingController();
  final eventStartDateController = TextEditingController();
  final eventEndDateController = TextEditingController();
  final eventRegistrationDeadlineController = TextEditingController();
  bool isPaymentRequired = false;
  File? image;
  File? video;

  String? selectedCategory;
  String? selectedType;
  String? categoryError;
  String? typeError;

  @override
  void initState() {
    super.initState();
    // Fetch categories when screen loads
    context.read<EventBloc>().add(FetchCategoriesEvent());
  }

  List<Step> getSteps() {
    return [
      Step(
        title: const Text('Basic Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppFormField(
              hint: 'Event Name',
              controller: eventNameController,
            ),
            SizedBox(height: Responsive.spacingHeight),
            AppFormField(
              hint: 'Event Description',
              controller: eventDescriptionController,
              maxLines: 4,
            ),
            SizedBox(height: Responsive.spacingHeight),
            const Text('Event Category'),
            SizedBox(height: Responsive.spacingHeight),
            BlocBuilder<EventBloc, EventState>(
              builder: (context, state) {
                if (state is CategoriesLoaded) {
                  final categories =
                      state.categories.map((c) => c.name).toList();
                  final eventTypes = state.categories
                      .expand((category) => category.eventTypes)
                      .map((type) => type.name)
                      .toList();

                  if (categories.isEmpty) {
                    return const Center(
                      child: Text(
                        'No categories available at this time',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Event Category'),
                      SizedBox(height: Responsive.spacingHeight),
                      if (categories.isEmpty) 
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'No categories available. Please try again later.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        DropDown(
                          dropDownKey: GlobalKey<DropdownSearchState>(),
                          items: categories,
                          selectedItem: selectedCategory,
                          hint: 'Select Category',
                          errorText: categoryError,
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                              categoryError = null;
                            });
                          },
                        ),
                      SizedBox(height: Responsive.spacingHeight),
                      const Text('Event Type'),
                      SizedBox(height: Responsive.spacingHeight),
                      if (eventTypes.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'No event types available for the selected category',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        DropDown(
                          dropDownKey: GlobalKey<DropdownSearchState>(),
                          items: eventTypes,
                          selectedItem: selectedType,
                          hint: 'Select Event Type',
                          errorText: typeError,
                          onChanged: (value) {
                            setState(() {
                              selectedType = value;
                              typeError = null;
                            });
                          },
                        ),
                    ],
                  );
                }

                if (state is EventError) {
                  return Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<EventBloc>().add(FetchCategoriesEvent());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  );
                }

                // Loading state
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            SizedBox(height: Responsive.spacingHeight),
            const Text('Payment Required'),
            ToggleButton(
              initialValue: isPaymentRequired,
              onChanged: (value) {
                setState(() {
                  isPaymentRequired = value;
                });
              },
            ),
            if (isPaymentRequired) ...[
              SizedBox(height: Responsive.spacingHeight),
              AppFormField(
                hint: 'Ticket Price',
                controller: eventTicketPriceController,
                keyboardType: TextInputType.number,
              ),
            ],
          ],
        ),
        isActive: currentStep >= 0,
      ),
      Step(
        title: const Text('Schedule & Capacity'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Event Time'),
            const ScrollTimePickerWheel(),
            SizedBox(height: Responsive.spacingHeight),
            AppFormField(
              hint: 'Location',
              controller: eventLocationController,
            ),
            SizedBox(height: Responsive.spacingHeight),
            AppFormField(
              hint: 'Participant Capacity',
              controller: eventParticipantCapacityController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: Responsive.spacingHeight),
            const Text('Start date time'),
            DateField(controller: eventStartDateController),
            SizedBox(height: Responsive.spacingHeight),
            const Text('End Date Time'),
            DateField(controller: eventEndDateController),
            SizedBox(height: Responsive.spacingHeight),
            const Text('Registration Deadline'),
            DateField(controller: eventRegistrationDeadlineController),
          ],
        ),
        isActive: currentStep >= 1,
      ),
      Step(
        title: const Text('Media'),
        content: Column(
          children: [
            _buildImagePicker(),
            SizedBox(height: Responsive.spacingHeight),
            _buildVideoPicker(),
          ],
        ),
        isActive: currentStep >= 2,
      ),
    ];
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () async {
        final selectedImage = await ImagePickerService.pickImageFromGallery();
        if (selectedImage != null) {
          setState(() {
            image = selectedImage;
          });
        }
      },
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
        ),
        child: image != null
            ? ImageCard(imageFile: image)
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Add Banner Image'),
                ],
              ),
      ),
    );
  }

  Widget _buildVideoPicker() {
    return GestureDetector(
      onTap: () async {
        final selectedVideo = await FilePickerService.pickFile();
        if (selectedVideo != null) {
          setState(() {
            video = selectedVideo;
          });
        }
      },
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
        ),
        child: video != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: VideoPlayer(
                  videoFile: video,
                  isFile: true,
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Add Promo Video'),
                ],
              ),
      ),
    );
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
        return 'Media Upload';
      default:
        return '';
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
        body: Form(
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
                      if (formKey.currentState!.validate()) {
                        // Your existing form submission logic
                      }
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
    );
  }

  @override
  void dispose() {
    eventNameController.dispose();
    eventDescriptionController.dispose();
    eventLocationController.dispose();
    eventTicketPriceController.dispose();
    eventParticipantCapacityController.dispose();
    eventStartDateController.dispose();
    eventEndDateController.dispose();
    eventRegistrationDeadlineController.dispose();
    super.dispose();
  }
}
