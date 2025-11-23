import 'package:flutter/material.dart';
import 'package:flutter_app/screens/analysis_screen.dart';
import 'package:flutter_app/screens/detection_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pumpkin Pollination App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pumpkin Pollination Readiness")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("Analysis Screen"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AnalysisScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text("Detection Screen"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DetectionScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
