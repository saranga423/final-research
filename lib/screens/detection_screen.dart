// ignore_for_file: control_flow_in_finally

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/image_picker_service.dart';
import '../services/image_processing_service.dart';
import '../providers/flower_provider.dart';
import 'package:image_picker/image_picker.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  final ImagePickerService _imagePickerService = ImagePickerService();
  bool _isLoading = false;

  Future<void> captureAndSend() async {
    setState(() => _isLoading = true);

    try {
      final XFile? xfile = await _imagePickerService.pickFromCamera();
      final File? imageFile = _imagePickerService.xfileToFile(xfile);
      if (imageFile == null) return;

      final base64Image = await ImageProcessingService().encodeImageToBase64(imageFile);

      if (!mounted) return;
      final flowerProvider = Provider.of<FlowerProvider>(context, listen: false);
      await flowerProvider.addFlower(base64Image);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Flower image uploaded")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flower Detection")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: captureAndSend,
                child: const Text("Capture Flower Image"),
              ),
      ),
    );
  }
}
