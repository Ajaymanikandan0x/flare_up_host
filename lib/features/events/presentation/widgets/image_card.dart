import 'package:flutter/material.dart';
import 'dart:io';
class ImageCard extends StatelessWidget {
  final File? imageFile;
  const ImageCard({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Image.file(
        imageFile!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
