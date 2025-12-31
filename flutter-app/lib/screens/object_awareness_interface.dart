// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/plant_perception_model.dart';
import 'package:provider/provider.dart';

import '../providers/plant_context_controller.dart';
import '../services/image_processing_service.dart';

class DetectionScreen extends StatelessWidget {
  const DetectionScreen({super.key});

  Future<void> captureAndSend(BuildContext context) async {
    final flowerProvider = Provider.of<FlowerProvider>(context, listen: false);

    try {
      // Implement actual camera capture
      final File dummyImage = File('');
      final imageService = ImageProcessingService();
      final base64Image = await imageService.encodeImageToBase64(dummyImage);

      // Create a new Flower object from the captured image
      final newFlower = Flower(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Captured Flower ${flowerProvider.flowers.length + 1}',
        species: 'Cucurbita moschata',
        fieldZone: 'Field Zone',
        imageBase64: base64Image,
        imageUrl: 'assets/captured_flower.jpg',
        readinessScore: 0.5,
        currentStage: FlowerDevelopmentStage.notReady,
      );

      flowerProvider.addFlower(newFlower);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flower image captured and analyzed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final flowerProvider = Provider.of<FlowerProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Flower Detection")),
      body: Center(
        child: flowerProvider.loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => captureAndSend(context),
                child: const Text("Capture Flower Image"),
              ),
      ),
    );
  }
}
