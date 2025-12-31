import 'package:flutter/foundation.dart';

class Flower {
  final String id;
  final String name;

  Flower({required this.id, required this.name});
}

class FlowerProvider with ChangeNotifier {
  bool loading = false;
  List<Flower> flowers = [];

  FlowerProvider() {
    // Optionally preload sample data
    loadFlowers();
  }

  Future<void> loadFlowers() async {
    loading = true;
    notifyListeners();

    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    flowers = [
      Flower(id: '1', name: 'Rose'),
      Flower(id: '2', name: 'Sunflower'),
      Flower(id: '3', name: 'Tulip'),
    ];

    loading = false;
    notifyListeners();
  }
}
