import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/image_picker_service.dart';
import '../../../../../core/utils/logger.dart';
import '../../../domain/entities/media_entity.dart';
import '../../../domain/repositories/event_repository.dart';
import '../../bloc/event_bloc.dart';
import '../../bloc/event_event.dart';
import '../../bloc/event_state.dart';

class ImageSection extends StatefulWidget {
  final Function(MediaEntity) onImageSelected;
  final File? existingImage;

  const ImageSection({
    super.key,
    required this.onImageSelected,
    this.existingImage,
  });

  @override
  State<ImageSection> createState() => _ImageSectionState();
}

class _ImageSectionState extends State<ImageSection> {
  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventBloc, EventBlocState>(
      listener: (context, state) {
        if (state is ImageSelectionState && state.url != null) {
          widget.onImageSelected(MediaEntity(
            file: state.selectedImage,
            url: state.url!,
          ));
        } else if (state is EventMediaUploadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        final displayImage = state is ImageSelectionState
            ? state.selectedImage
            : widget.existingImage;

        return GestureDetector(
          onTap: () async {
            try {
              final image = await ImagePickerService.pickImageFromGallery();
              if (image != null) {
                Logger.debug('Image selected: ${image.path}');
                context.read<EventBloc>()
                  ..add(SelectImageEvent(image))
                  ..add(const SetImageUploadingEvent(true))
                  ..add(UploadEventMediaEvent(
                    file: image,
                    type: MediaType.image,
                  ));
              }
            } catch (e) {
              Logger.error('Error selecting image:', e);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error selecting image: $e')),
              );
            }
          },
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: displayImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      displayImage,
                      fit: BoxFit.cover,
                    ),
                  )
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
      },
    );
  }
}
