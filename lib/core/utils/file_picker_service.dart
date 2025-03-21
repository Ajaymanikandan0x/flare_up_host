import 'dart:io';

import 'package:file_picker/file_picker.dart';
import '../utils/logger.dart';

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
    try {
      Logger.debug('Initializing video picker with custom type');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'avi'],
        allowMultiple: false,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        Logger.debug('Video picked successfully: ${file.path}');
        return file;
      } else {
        Logger.debug('Video picker cancelled by user');
        return null;
      }
    } catch (e) {
      Logger.error('Error in pickVideo:', e);
      rethrow;
    }
  }
}
