import 'dart:convert';
import 'dart:io';

import '../config/constants.dart';

class ApiService {
  Future<dynamic> sendImageForPrediction(String base64Image) async {
    final uri = Uri.parse("${AppConstants.apiBaseUrl}/predict");
    final client = HttpClient();
    try {
      final request = await client.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(jsonEncode({"image": base64Image}));
      final response = await request.close();

      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(body);
      } else {
        throw HttpException('Request failed with status: ${response.statusCode}', uri: uri);
      }
    } finally {
      client.close();
    }
  }
}
