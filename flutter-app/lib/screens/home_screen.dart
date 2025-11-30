import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Module')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt, size: 100, color: Colors.green),
          const SizedBox(height: 20),
          const Text(
            'Camera Feed Placeholder',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // integrate camera capture functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Photo Captured!')),
              );
            },
            icon: const Icon(Icons.photo_camera),
            label: const Text('Capture Photo'),
          ),
        ],
      ),
    );
  }
}

class ReadinessScreen extends StatelessWidget {
  const ReadinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Readiness Check')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'System Readiness Status',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Example readiness checklist
            Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.bolt, color: Colors.green),
                  title: Text('Battery Charged'),
                ),
                ListTile(
                  leading: Icon(Icons.cloud, color: Colors.green),
                  title: Text('Network Connected'),
                ),
                ListTile(
                  leading: Icon(Icons.security, color: Colors.green),
                  title: Text('Sensors OK'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All Systems Go!')),
                );
              },
              child: const Text('Run Readiness Check'),
            ),
          ],
        ),
      ),
    );
  }
}

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
      appBar: AppBar(title: const Text('Drone Control')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Icon(Icons.airplanemode_active, size: 100),
                const SizedBox(height: 10),
                Text(
                  "Status: $_status",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pollination Analyzer")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("Camera Module"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CameraScreen()));
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text("Readiness Check"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ReadinessScreen()));
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text("Drone Control"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DroneScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: HomeScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
