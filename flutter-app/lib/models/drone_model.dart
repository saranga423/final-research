// models/drone_model.dart

class Drone {
  final String id;
  final String name;
  final double batteryLevel; // 0.0 to 100.0
  final double altitude; // in meters
  final double latitude;
  final double longitude;
  final bool isActive;

  Drone({
    required this.id,
    required this.name,
    required this.batteryLevel,
    required this.altitude,
    required this.latitude,
    required this.longitude,
    required this.isActive,
  });

  /// Create a Drone object from a Firestore document
  factory Drone.fromMap(String id, Map<String, dynamic> data) {
    return Drone(
      id: id,
      name: data['name'] ?? 'Unnamed Drone',
      batteryLevel: (data['batteryLevel'] ?? 0).toDouble(),
      altitude: (data['altitude'] ?? 0).toDouble(),
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      isActive: data['isActive'] ?? false,
    );
  }

  /// Convert Drone object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'batteryLevel': batteryLevel,
      'altitude': altitude,
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
    };
  }
}
