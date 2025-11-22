import 'package:flutter/material.dart';
import '../models/flower_model.dart';

class FlowerCard extends StatelessWidget {
  final Flower flower;

  const FlowerCard({super.key, required this.flower});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Image.network(flower.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
        title: Text("Gender: ${flower.gender}"),
        subtitle: Text("Readiness Score: ${flower.readinessScore.toStringAsFixed(2)}"),
      ),
    );
  }
}
