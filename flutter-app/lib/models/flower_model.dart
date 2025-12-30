class Flower {
  final String id;
  final String name;
  final String species;
  final String fieldZone;
  final DateTime plantedDate;
  final String imageBase64;
  final String imageUrl;
  final double readinessScore;
  FlowerDevelopmentStage currentStage;
  final List<DevelopmentRecord> developmentHistory;
  final List<SensorReading> sensorReadings;

  DateTime? estimatedReadyTime;
  DateTime? readyTime;
  DateTime? pastPollinationTime;
  double pollutionSuccessScore;

  Flower({
    required this.id,
    required this.name,
    this.species = 'Cucurbita moschata',
    this.fieldZone = 'Unknown',
    DateTime? plantedDate,
    this.currentStage = FlowerDevelopmentStage.notReady,
    this.developmentHistory = const [],
    this.sensorReadings = const [],
    this.estimatedReadyTime,
    this.readyTime,
    this.pastPollinationTime,
    this.pollutionSuccessScore = 0.0,
    this.imageBase64 = '',
    this.imageUrl = '',
    this.readinessScore = 0.0,
  }) : plantedDate = plantedDate ?? DateTime.now();

  double getDevDaysSinceReady() {
    if (readyTime == null) return -1;
    return DateTime.now().difference(readyTime!).inHours / 24.0;
  }

  bool isPollinationWindow() {
    if (currentStage != FlowerDevelopmentStage.ready) return false;
    final daysSinceReady = getDevDaysSinceReady();
    return daysSinceReady >= 0 && daysSinceReady < 3; // 3-day window
  }
}

enum FlowerDevelopmentStage {
  notReady,
  ready,
  pastPollination,
  unknown,
}

class DevelopmentRecord {
  final DateTime timestamp;
  final FlowerDevelopmentStage stage;
  final double classificationConfidence;
  final String imageUrl;

  DevelopmentRecord({
    required this.timestamp,
    required this.stage,
    required this.classificationConfidence,
    required this.imageUrl,
  });
}

class SensorReading {
  final DateTime timestamp;
  final double temperature; // Celsius
  final double humidity; // Percentage
  final double lightIntensity; // Lux
  final double soilMoisture; // Percentage

  SensorReading({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.lightIntensity,
    required this.soilMoisture,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'temperature': temperature,
        'humidity': humidity,
        'lightIntensity': lightIntensity,
        'soilMoisture': soilMoisture,
      };
}

class PollutionUrgencyLevel {
  final String level; // 'low', 'medium', 'high', 'critical'
  final String reason;
  final Duration estimatedWindow;
  final List<String> recommendedActions;

  PollutionUrgencyLevel({
    required this.level,
    required this.reason,
    required this.estimatedWindow,
    required this.recommendedActions,
  });
}
