import 'package:flutter/material.dart';
import '../models/decision_readiness_model.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder analysis data
    final List<ReadinessResult> results = [
      ReadinessResult(score: 0.85, isReady: true),
      ReadinessResult(score: 0.45, isReady: false),
      ReadinessResult(score: 0.78, isReady: true),
      
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Analysis Results")),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(
                result.isReady ? Icons.check_circle : Icons.cancel,
                color: result.isReady ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
              ),
              title: Text("Flower ${index + 1}"),
              subtitle: Text("Readiness Score: ${result.score.toStringAsFixed(2)}"),
            ),
          );
        },
      ),
    );
  }
}

