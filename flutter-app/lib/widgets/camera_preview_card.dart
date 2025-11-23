import 'package:flutter/material.dart';

class CameraPreviewCard extends StatelessWidget {
  final String label;
  final Widget? child;

  const CameraPreviewCard({
    Key? key,
    this.label = "Camera Feed",
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[300],
            child: child ??
                const Center(
                  child: Icon(
                    Icons.videocam,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
