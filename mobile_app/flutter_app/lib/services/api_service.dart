
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  static Future<String> uploadImage(File image) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('\$baseUrl/predict-flower'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', image.path));
    var response = await request.send();
    return response.statusCode == 200 ? "Success" : "Failed";
  }
}
