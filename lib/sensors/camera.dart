// sensors/camera.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraSensor {
  final ImagePicker _picker = ImagePicker();

  /// Captures an image using the device camera
  Future<File?> captureImage() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // optional, reduce image size
      );
      if (photo == null) return null;
      return File(photo.path);
    } catch (e) {
      print("Error capturing image: $e");
      return null;
    }
  }

  /// Picks an image from the gallery (optional)
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (photo == null) return null;
      return File(photo.path);
    } catch (e) {
      print("Error picking image: $e");
      return null;
    }
  }
}
