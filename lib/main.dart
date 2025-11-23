import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/flower_provider.dart';
import 'providers/drone_provider.dart';
// Removed unused screen imports

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FlowerProvider()),
        ChangeNotifierProvider(create: (_) => DroneProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
