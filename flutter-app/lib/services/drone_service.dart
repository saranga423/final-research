class DroneService {
  Future<bool> connectToDrone() async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<String> sendCommand(String cmd) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return "ACK: $cmd";
  }
}
