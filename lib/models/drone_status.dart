class DroneStatus {
  final bool isConnected;
  final double batteryLevel;
  final String mode;
  final double readinessScore;
  final double altitude;


  DroneStatus({
    required this.isConnected,
    required this.batteryLevel,
    required this.mode,
    required this.readinessScore,
    required this.altitude,
    
  });
}
