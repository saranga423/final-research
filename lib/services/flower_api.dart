import 'dart:convert';

import 'package:http/http.dart' as http;

class FlowerApi {
  final String baseUrl = "http://localhost:3000/api/flowers";

  Future<List<dynamic>> getFlowers() async {
    final response = await http.get(Uri.parse(baseUrl));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> addFlower(String base64Image) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Image}),
    );
    return jsonDecode(response.body);
  }
}
