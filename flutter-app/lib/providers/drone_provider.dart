import 'package:flutter/material.dart';
import '../services/drone_service.dart';
import '../models/drone_status.dart';

class DroneProvider extends ChangeNotifier {
  final DroneService _droneService = DroneService();

  DroneStatus _status = DroneStatus(isConnected: false, batteryLevel: 0, mode: 'Idle');
  DroneStatus get status => _status;

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
}
