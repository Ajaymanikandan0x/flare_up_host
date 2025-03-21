import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FilePickerService {
  static Future<File?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      return File(result.files.single.path!);
    } else {
      return null;
    }
  }

  static Future<File?> pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowedExtensions: ['mp4', 'mov', 'avi'],
    );

    if (result != null) {
      return File(result.files.single.path!);
    } else {
      return null;
    }
  }
}
