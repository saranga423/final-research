import 'package:flutter/material.dart';

import '../models/flower_model.dart';

class FlowerProvider extends ChangeNotifier {
  final List<Flower> _flowers = [];

  List<Flower> get flowers => _flowers;

  bool get loading => false;

  void addFlower(Flower flower) {
    _flowers.add(flower);
    notifyListeners();
  }

  void removeFlower(Flower flower) {
    _flowers.remove(flower);
    notifyListeners();
  }

  loadFlowers() {}

  void exportData() {}
}
