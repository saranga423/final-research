// ignore_for_file: avoid_print

import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  Future<XFile?> pickFromCamera() async {
    try {
      return await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    } catch (e) {
      print("Error picking image: $e");
      return null;
    }
  }

  /// Pick image from gallery
  Future<XFile?> pickFromGallery() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    } catch (e) {
      print("Error picking image: $e");
      return null;
    }
  }

  /// Convert XFile to Dart File
  File? xfileToFile(XFile? xfile) {
    if (xfile == null) return null;
    return File(xfile.path);
  }
}
