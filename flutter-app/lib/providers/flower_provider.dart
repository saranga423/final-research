// ignore_for_file: prefer_final_fields

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/flower_model.dart';
import '../services/time_series_predictor.dart';

class FlowerProvider extends ChangeNotifier {
  List<Flower> _flowers = [];
  Map<String, PollutionUrgencyLevel> _urgencyLevels = {};
  bool _loading = false;

  List<Flower> get flowers => _flowers;
  Map<String, PollutionUrgencyLevel> get urgencyLevels => _urgencyLevels;
  bool get loading => _loading;

  Future<void> loadFlowers() async {
    _loading = true;
    notifyListeners();

    // Ttodo Load from backend/database
    _flowers = [
      Flower(
        id: '1',
        name: 'Pumpkin Plant A',
        species: 'Cucurbita moschata',
        fieldZone: 'Zone A',
        plantedDate: DateTime.now().subtract(const Duration(days: 45)),
        currentStage: FlowerDevelopmentStage.ready,
        developmentHistory: [
          DevelopmentRecord(
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            stage: FlowerDevelopmentStage.notReady,
            classificationConfidence: 0.92,
            imageUrl: 'assets/flower_not_ready.jpg',
          ),
          DevelopmentRecord(
            timestamp: DateTime.now(),
            stage: FlowerDevelopmentStage.ready,
            classificationConfidence: 0.95,
            imageUrl: 'assets/flower_ready.jpg',
          ),
        ],
        readyTime: DateTime.now(),
        estimatedReadyTime: DateTime.now(),
      ),
      Flower(
        id: '2',
        name: 'Pumpkin Plant B',
        species: 'Cucurbita maxima',
        fieldZone: 'Zone B',
        plantedDate: DateTime.now().subtract(const Duration(days: 42)),
        currentStage: FlowerDevelopmentStage.notReady,
      ),
    ];

    _loading = false;
    notifyListeners();
  }

  void addFlower(Flower flower) {
    _flowers.add(flower);

    // Update predictions for new flower
    if (flower.sensorReadings.isNotEmpty) {
      _updatePredictions(flower.id);
    }

    notifyListeners();
  }

  void updateFlowerStage(String flowerId, FlowerDevelopmentStage newStage) {
    final flowerIndex = _flowers.indexWhere((f) => f.id == flowerId);
    if (flowerIndex != -1) {
      _flowers[flowerIndex].currentStage = newStage;
      _updatePredictions(flowerId);
      notifyListeners();
    }
  }

  void addSensorReading(String flowerId, SensorReading reading) {
    final flowerIndex = _flowers.indexWhere((f) => f.id == flowerId);
    if (flowerIndex != -1) {
      _flowers[flowerIndex].sensorReadings.add(reading);
      _updatePredictions(flowerId);
      notifyListeners();
    }
  }

  void _updatePredictions(String flowerId) {
    final flowerIndex = _flowers.indexWhere((f) => f.id == flowerId);
    if (flowerIndex == -1) return;

    final flower = _flowers[flowerIndex];

    // Update estimated ready time
    flower.estimatedReadyTime = TimeSeriesPredictor.predictReadyTime(
        flower,
        flower.sensorReadings.sublist((flower.sensorReadings.length - 24)
            .clamp(0, flower.sensorReadings.length)));

    // Update urgency level
    if (flower.sensorReadings.isNotEmpty) {
      _urgencyLevels[flowerId] = TimeSeriesPredictor.assessUrgencyLevel(
        flower,
        flower.sensorReadings.last,
      );
    }

    // Update pollination success score
    if (flower.currentStage == FlowerDevelopmentStage.pastPollination) {
      flower.pollutionSuccessScore =
          TimeSeriesPredictor.assessPollinationSuccess(flower);
    }
  }

  PollutionUrgencyLevel? getUrgencyLevel(String flowerId) {
    return _urgencyLevels[flowerId];
  }

  List<Flower> getReadyFlowers() {
    return _flowers
        .where((f) => f.currentStage == FlowerDevelopmentStage.ready)
        .toList();
  }

  List<Flower> getHighUrgencyFlowers() {
    return _flowers.where((f) {
      final urgency = _urgencyLevels[f.id];
      return urgency != null &&
          (urgency.level == 'critical' || urgency.level == 'high');
    }).toList();
  }

  void exportData() {
    debugPrint('Exporting ${_flowers.length} flowers with sensor data');
  }
}
