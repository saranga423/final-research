import '../models/plant_perception_model.dart';

class TimeSeriesPredictor {
  static const double temperatureOptimalMin = 20.0;
  static const double temperatureOptimalMax = 28.0;
  static const double humidityOptimalMin = 50.0;
  static const double humidityOptimalMax = 80.0;
  static const double lightIntensityOptimalMin = 500.0;
  static const double soilMoistureOptimal = 60.0;

  /// Calculate average duration from "not ready" to "ready" stage
  static Duration calculateAverageStageDuration(
      List<DevelopmentRecord> history) {
    if (history.isEmpty) return const Duration(days: 7);

    final notReadyRecords =
        history.where((r) => r.stage == FlowerDevelopmentStage.notReady);
    final readyRecords =
        history.where((r) => r.stage == FlowerDevelopmentStage.ready);

    if (notReadyRecords.isEmpty || readyRecords.isEmpty) {
      return const Duration(days: 7);
    }

    final lastNotReady = notReadyRecords.last.timestamp;
    final firstReady = readyRecords.first.timestamp;

    return firstReady.difference(lastNotReady);
  }

  /// Predict the exact time flower will reach ready stage
  static DateTime? predictReadyTime(
      Flower flower, List<SensorReading> recentSensorData) {
    if (flower.currentStage == FlowerDevelopmentStage.ready) {
      return DateTime.now();
    }

    if (flower.developmentHistory.isEmpty) return null;

    final avgDuration =
        calculateAverageStageDuration(flower.developmentHistory);
    final lastRecord = flower.developmentHistory.last;

    if (lastRecord.stage == FlowerDevelopmentStage.notReady) {
      // Apply sensor-based adjustment factor
      final adjustmentFactor =
          _calculateSensorAdjustmentFactor(recentSensorData);
      final adjustedDuration = Duration(
        days: (avgDuration.inDays * adjustmentFactor).toInt(),
      );
      return lastRecord.timestamp.add(adjustedDuration);
    }

    return null;
  }

  /// Calculate sensor-based adjustment to development timeline
  static double _calculateSensorAdjustmentFactor(
      List<SensorReading> sensorData) {
    if (sensorData.isEmpty) return 1.0;

    double temperatureScore = 0.0;
    double humidityScore = 0.0;
    double lightScore = 0.0;
    double moistureScore = 0.0;

    for (final reading in sensorData) {
      // Temperature scoring (0-1, where 1 is optimal)
      temperatureScore += _scoreTemperature(reading.temperature);
      // Humidity scoring
      humidityScore += _scoreHumidity(reading.humidity);
      // Light intensity scoring
      lightScore += _scoreLightIntensity(reading.lightIntensity);
      // Soil moisture scoring
      moistureScore += _scoreSoilMoisture(reading.soilMoisture);
    }

    final count = sensorData.length;
    final avgScore =
        (temperatureScore + humidityScore + lightScore + moistureScore) /
            (4 * count);

    // Adjustment factor: 0.7 to 1.3 based on conditions
    return 0.7 + (avgScore * 0.6);
  }

  static double _scoreTemperature(double temp) {
    if (temp >= temperatureOptimalMin && temp <= temperatureOptimalMax) {
      return 1.0;
    }
    final distance = (temp < temperatureOptimalMin)
        ? temperatureOptimalMin - temp
        : temp - temperatureOptimalMax;
    return (1.0 - (distance / 10.0)).clamp(0.0, 1.0);
  }

  static double _scoreHumidity(double humidity) {
    if (humidity >= humidityOptimalMin && humidity <= humidityOptimalMax) {
      return 1.0;
    }
    final distance = (humidity < humidityOptimalMin)
        ? humidityOptimalMin - humidity
        : humidity - humidityOptimalMax;
    return (1.0 - (distance / 30.0)).clamp(0.0, 1.0);
  }

  static double _scoreLightIntensity(double intensity) {
    if (intensity >= lightIntensityOptimalMin) return 1.0;
    return (intensity / lightIntensityOptimalMin).clamp(0.0, 1.0);
  }

  static double _scoreSoilMoisture(double moisture) {
    final distance = (moisture - soilMoistureOptimal).abs();
    return (1.0 - (distance / 40.0)).clamp(0.0, 1.0);
  }

  /// Determine pollination urgency based on current state and sensor data
  static PollutionUrgencyLevel assessUrgencyLevel(
      Flower flower, SensorReading latestSensorData) {
    if (flower.currentStage != FlowerDevelopmentStage.ready) {
      return PollutionUrgencyLevel(
        level: 'low',
        reason: 'Flower not yet ready for pollination',
        estimatedWindow: const Duration(hours: 0),
        recommendedActions: ['Monitor developmental progress'],
      );
    }

    // Scenario A: High urgency (Ready + poor conditions)
    if (latestSensorData.temperature > temperatureOptimalMax &&
        latestSensorData.humidity < humidityOptimalMin) {
      return PollutionUrgencyLevel(
        level: 'critical',
        reason:
            'High temperature (${latestSensorData.temperature}°C) and low humidity (${latestSensorData.humidity}%) shorten receptivity window',
        estimatedWindow: const Duration(hours: 4),
        recommendedActions: [
          'Deploy robot immediately',
          'Increase field irrigation',
          'Monitor receptivity closely',
        ],
      );
    }

    // Scenario B: Extended window (Ready + ideal conditions)
    if (latestSensorData.temperature >= temperatureOptimalMin &&
        latestSensorData.temperature <= temperatureOptimalMax &&
        latestSensorData.humidity >= humidityOptimalMin &&
        latestSensorData.humidity <= humidityOptimalMax) {
      return PollutionUrgencyLevel(
        level: 'low',
        reason:
            'Ideal environmental conditions extend receptivity window significantly',
        estimatedWindow: const Duration(hours: 18),
        recommendedActions: [
          'Schedule robot deployment flexibly',
          'Maintain current irrigation',
          'Monitor for any condition changes',
        ],
      );
    }

    // Default: Medium urgency
    return PollutionUrgencyLevel(
      level: 'medium',
      reason: 'Flower ready with moderate environmental conditions',
      estimatedWindow: const Duration(hours: 10),
      recommendedActions: [
        'Prepare robot for deployment',
        'Monitor environmental changes',
        'Plan deployment within 6 hours',
      ],
    );
  }

  /// Assess pollination success based on timing and conditions
  static double assessPollinationSuccess(Flower flower) {
    if (!flower.isPollinationWindow()) return 0.0;

    double score = 1.0;

    // Factor 1: Timing within window
    final daysSinceReady = flower.getDevDaysSinceReady();
    if (daysSinceReady > 1) {
      score -= (daysSinceReady - 1) * 0.15; // Deduct for delayed pollination
    }

    // Factor 2: Latest sensor conditions
    if (flower.sensorReadings.isNotEmpty) {
      final latestReading = flower.sensorReadings.last;
      score *= _scoreTemperature(latestReading.temperature);
      score *= _scoreHumidity(latestReading.humidity);
      score *= _scoreLightIntensity(latestReading.lightIntensity);
    }

    return score.clamp(0.0, 1.0);
  }
}
