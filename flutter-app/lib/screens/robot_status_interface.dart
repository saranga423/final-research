import 'package:flutter/material.dart';

class DroneScreen extends StatefulWidget {
  const DroneScreen({super.key});

  @override
  State<DroneScreen> createState() => _DroneScreenState();
}

class _DroneScreenState extends State<DroneScreen> {
  bool _isFlying = false;
  String _status = "Idle";

  void _takeOff() {
    setState(() {
      _isFlying = true;
      _status = "Flying";
    });
  }

  void _land() {
    setState(() {
      _isFlying = false;
      _status = "Landed";
    });
  }

  void _move(String direction) {
    if (!_isFlying) return;
    setState(() {
      _status = "Moving $direction";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Drone Control")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Drone Status Display
            Column(
              children: [
                const Icon(Icons.airplanemode_active, size: 100),
                const SizedBox(height: 10),
                Text(
                  "Status: $_status",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  _isFlying ? "Drone is airborne" : "Drone is grounded",
                  style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
              ],
            ),

            // Control Buttons
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _isFlying ? null : _takeOff,
                      child: const Text("Take Off"),
                    ),
                    ElevatedButton(
                      onPressed: _isFlying ? _land : null,
                      child: const Text("Land"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Directional Controls
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _move("Forward"),
                      child: const Icon(Icons.arrow_upward),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => _move("Left"),
                          child: const Icon(Icons.arrow_back),
                        ),
                        ElevatedButton(
                          onPressed: () => _move("Right"),
                          child: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _move("Backward"),
                      child: const Icon(Icons.arrow_downward),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
