import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/image_picker_service.dart';
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
  void initState() {
    super.initState();
    selectedImage = widget.existingImage;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventBlocState>(
      listener: (context, state) {
        if (state is EventMediaUploadSuccess) {
          widget.onImageSelected(MediaEntity(
            file: selectedImage,
            url: state.url,
          ));
        }
      },
      child: GestureDetector(
        onTap: () async {
          final image = await ImagePickerService.pickImageFromGallery();
          if (image != null) {
            setState(() {
              selectedImage = image;
            });
            context.read<EventBloc>().add(
                  UploadEventMediaEvent(
                    file: image,
                    type: MediaType.image,
                  ),
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
          child: selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    selectedImage!,
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
      ),
    );
  }
}