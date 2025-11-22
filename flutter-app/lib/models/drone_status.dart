class DroneStatus {
  final bool isConnected;
  final double batteryLevel;
  final String mode;

  DroneStatus({
    required this.isConnected,
    required this.batteryLevel,
    required this.mode,
  });
}
