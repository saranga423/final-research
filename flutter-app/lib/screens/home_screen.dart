import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Module')),
      body: const Center(child: Text('Camera Screen Placeholder')),
    );
  }
}

class ReadinessScreen extends StatelessWidget {
  const ReadinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Readiness Check')),
      body: const Center(child: Text('Readiness Screen Placeholder')),
    );
  }
}

class DroneScreen extends StatelessWidget {
  const DroneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drone Control')),
      body: const Center(child: Text('Drone Screen Placeholder')),
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
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraScreen()));
              },
            ),
            ElevatedButton(
              child: const Text("Readiness Check"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadinessScreen()));
              },
            ),
            ElevatedButton(
              child: const Text("Drone Control"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DroneScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
