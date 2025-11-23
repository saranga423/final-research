import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const SensorCard({
    super.key,
    required this.label,
    required this.value,
    this.icon = Icons.device_thermostat,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  value,
                  style: textTheme.titleLarge?.copyWith(color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
