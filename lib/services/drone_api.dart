import 'dart:convert';

import 'package:http/http.dart' as http;

class DroneApi {
  final String baseUrl = "http://localhost:3000/api/drone";

  Future<Map<String, dynamic>> getStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/status'));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> takeoff() async {
    final response = await http.post(Uri.parse('$baseUrl/takeoff'));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> land() async {
    final response = await http.post(Uri.parse('$baseUrl/land'));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> setSpeed(int speed) async {
    final response = await http.post(
      Uri.parse('$baseUrl/speed'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'speed': speed}),
    );
    return jsonDecode(response.body);
  }
}
