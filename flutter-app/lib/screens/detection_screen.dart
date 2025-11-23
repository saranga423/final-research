import 'package:flutter/material.dart';
import '../services/image_processing_service.dart';
import '../providers/flower_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class DetectionScreen extends StatelessWidget {
  const DetectionScreen({super.key});

  Future<void> captureAndSend(BuildContext context) async {
    // TODO: Implement actual camera capture
    final File dummyImage = File(''); // placeholder
    final imageService = ImageProcessingService();
    final base64Image = await imageService.encodeImageToBase64(dummyImage);

    final flowerProvider = Provider.of<FlowerProvider>(context, listen: false);
    await flowerProvider.addFlower(base64Image);
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
