import 'dart:io';
import 'dart:convert';

class ImageProcessingService {
  Future<String> encodeImageToBase64(File image) async {
    final bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }
}
