import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/flower_model.dart';

class FirebaseService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (!_initialized) {
      await Firebase.initializeApp();
      _initialized = true;
    }
  }

  final CollectionReference _flowerCollection =
      FirebaseFirestore.instance.collection('flowers');

  Future<void> addFlower(Flower flower) async {
    await _flowerCollection.doc(flower.id).set({
      'name': flower.name,
      'species': flower.species,
      'fieldZone': flower.fieldZone,
      'imageUrl': flower.imageUrl,
      'readinessScore': flower.readinessScore,
      'currentStage': flower.currentStage.name,
      'plantedDate': flower.plantedDate.toIso8601String(),
    });
  }

  Stream<List<Flower>> getFlowers() {
    return _flowerCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Flower(
          id: doc.id,
          name: data['name'] ?? 'Unknown',
          species: data['species'] ?? 'Cucurbita moschata',
          fieldZone: data['fieldZone'] ?? 'Unknown',
          imageUrl: data['imageUrl'] ?? '',
          readinessScore: (data['readinessScore'] ?? 0).toDouble(),
          imageBase64: '',
          plantedDate: data['plantedDate'] != null
              ? DateTime.parse(data['plantedDate'] as String)
              : DateTime.now(),
          currentStage: _parseStage(data['currentStage']),
        );
      }).toList();
    });
  }

  FlowerDevelopmentStage _parseStage(String? stageName) {
    if (stageName == null) return FlowerDevelopmentStage.notReady;
    try {
      return FlowerDevelopmentStage.values.firstWhere(
        (stage) => stage.name == stageName,
        orElse: () => FlowerDevelopmentStage.notReady,
      );
    } catch (_) {
      return FlowerDevelopmentStage.notReady;
    }
  }
}
