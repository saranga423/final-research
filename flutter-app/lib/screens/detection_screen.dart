// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/flower_model.dart';
import 'package:provider/provider.dart';

import '../providers/flower_provider.dart';
import '../services/image_processing_service.dart';

class DetectionScreen extends StatelessWidget {
  const DetectionScreen({super.key});

  Future<void> captureAndSend(BuildContext context) async {
    // Implement actual camera capture
    final File dummyImage = File('');
    final imageService = ImageProcessingService();
    final base64Image = await imageService.encodeImageToBase64(dummyImage);

    final flowerProvider = Provider.of<FlowerProvider>(context, listen: false);
    // create a Flower object from the base64 image and add it to the provider
    flowerProvider.addFlower(
        Flower(imageBase64: base64Image, id: '', imageUrl: '', gender: '', readinessScore: 0.0));
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
