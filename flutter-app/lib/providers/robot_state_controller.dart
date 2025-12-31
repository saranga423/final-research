import 'package:flutter/material.dart';

import '../models/robot_operational_state.dart';
import '../services/robot_action_service.dart';

class DroneProvider extends ChangeNotifier {
  final DroneService _droneService = DroneService();

  DroneStatus _status = DroneStatus(isConnected: false, batteryLevel: 0, mode: 'Idle');
  DroneStatus get status => _status;

  get droneStatus => null;

  bool? get isFlying => null;

  get lastTelemetry => null;

  Future<void> connect() async {
    bool connected = await _droneService.connectToDrone();
    _status = DroneStatus(isConnected: connected, batteryLevel: 100, mode: 'Idle');
    notifyListeners();
  }

  Future<void> sendCommand(String cmd) async {
    final response = await _droneService.sendCommand(cmd);
    debugPrint('Drone Response: $response');
    notifyListeners();
  }

  initializeDrone() {}

  void syncStatus() {}

  void stop() {}

  void start() {}
}
