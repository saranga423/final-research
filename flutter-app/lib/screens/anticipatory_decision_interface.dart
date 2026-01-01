// lib/screens/predictive_analytics_screen.dart
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plant_context_controller.dart';
import '../models/plant_perception_model.dart';

class PredictiveAnalyticsScreen extends StatelessWidget {
  const PredictiveAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flowerProv = Provider.of<FlowerProvider>(context);
    final highUrgencyFlowers = flowerProv.getHighUrgencyFlowers();
    final readyFlowers = flowerProv.getReadyFlowers();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Predictive Analytics & Forecasting',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (highUrgencyFlowers.isNotEmpty) ...[
            Text(
              'High Priority Alerts',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
            ...highUrgencyFlowers.map(
                (flower) => _buildUrgencyAlert(context, flowerProv, flower)),
            const SizedBox(height: 16),
          ],
          const Text(
            'Ready for Pollination',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (readyFlowers.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No flowers currently ready for pollination.'),
              ),
            )
          else
            ...readyFlowers.map((flower) =>
                _buildFlowerPredictionCard(context, flowerProv, flower)),
        ],
      ),
    );
  }

  Widget _buildUrgencyAlert(
      BuildContext context, FlowerProvider prov, Flower flower) {
    final urgency = prov.getUrgencyLevel(flower.id);
    if (urgency == null) return const SizedBox.shrink();

    final urgencyColor = urgency.level == 'critical'
        ? Colors.red
        : urgency.level == 'high'
            ? Colors.orange
            : Colors.yellow;

    return Card(
      color: urgencyColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: urgencyColor, width: 2),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flower.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        urgency.reason,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: urgencyColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    urgency.level.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Receptivity Window: ${urgency.estimatedWindow.inHours} hours',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Recommended Actions:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            ...urgency.recommendedActions.map((action) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(action,
                              style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowerPredictionCard(
      BuildContext context, FlowerProvider prov, Flower flower) {
    final urgency = prov.getUrgencyLevel(flower.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(Icons.local_florist, color: Theme.of(context).colorScheme.primary),
        title: Text(flower.name),
        subtitle: Text('${flower.species} - ${flower.fieldZone}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Current Stage', flower.currentStage.name),
                _buildInfoRow(
                    'Ready Since',
                    flower.readyTime != null
                        ? _formatTime(flower.readyTime!)
                        : 'N/A'),
                _buildInfoRow('Days in Window',
                    flower.getDevDaysSinceReady().toStringAsFixed(1)),
                if (urgency != null) ...[
                  const Divider(),
                  _buildInfoRow('Urgency Level', urgency.level.toUpperCase()),
                  _buildInfoRow('Window Duration',
                      '${urgency.estimatedWindow.inHours} hours'),
                ],
                if (flower.sensorReadings.isNotEmpty) ...[
                  const Divider(),
                  const Text(
                    'Latest Sensor Readings:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _buildSensorCard(flower.sensorReadings.last),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildSensorCard(SensorReading reading) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildSensorRow(
              '🌡️ Temperature', '${reading.temperature.toStringAsFixed(1)}°C'),
          _buildSensorRow(
              '💧 Humidity', '${reading.humidity.toStringAsFixed(1)}%'),
          _buildSensorRow('☀️ Light Intensity',
              '${reading.lightIntensity.toStringAsFixed(0)} Lux'),
          _buildSensorRow('🌱 Soil Moisture',
              '${reading.soilMoisture.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _buildSensorRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.month}/${dateTime.day}';
  }
}
