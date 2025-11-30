import 'package:flutter/material.dart';
import '../models/flower_model.dart';
import '../services/api_service.dart';


class FlowerProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  final List<Flower> _flowers = [];
  List<Flower> get flowers => _flowers;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> addFlower(String base64Image) async {
    _loading = true;
    notifyListeners();

    try {
      final result = await _apiService.sendImageForPrediction(base64Image);
      // Assume API returns id, gender, score, imageUrl
      final flower = Flower(
        altitude: result['altitude'],
        id: result['id'],
        gender: result['gender'],
        readinessScore: result['score'],
        imageUrl: result['imageUrl'],
      );
      _flowers.add(flower);
    } catch (e) {
      debugPrint('Error adding flower: $e');
    }

    _loading = false;
    notifyListeners();
  }
}
