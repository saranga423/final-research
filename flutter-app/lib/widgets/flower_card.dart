// ignore_for_file: deprecated_member_use

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
        leading: flower.imageUrl.isNotEmpty
            ? Image.network(flower.imageUrl,
                width: 50, height: 50, fit: BoxFit.cover)
            : Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
                child: const Icon(Icons.local_florist, color: Colors.green),
              ),
        title: Text(flower.name),
        subtitle: Text('${flower.species} - ${flower.fieldZone}'),
        trailing: _buildStageIndicator(flower.currentStage),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing ${flower.name} details')),
          );
        },
      ),
    );
  }

  Widget _buildStageIndicator(FlowerDevelopmentStage stage) {
    final stageColor = stage == FlowerDevelopmentStage.ready
        ? Colors.green
        : stage == FlowerDevelopmentStage.pastPollination
            ? Colors.blue
            : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: stageColor.withOpacity(0.2),
        border: Border.all(color: stageColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        stage.name,
        style: TextStyle(
          color: stageColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
