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

  final CollectionReference _flowerCollection = FirebaseFirestore.instance.collection('flowers');

  Future<void> addFlower(Flower flower) async {
    await _flowerCollection.doc(flower.id).set({
      'imageUrl': flower.imageUrl,
      'gender': flower.gender,
      'readinessScore': flower.readinessScore,
    });
  }

  Stream<List<Flower>> getFlowers() {
    return _flowerCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Flower(
          id: doc.id,
          imageUrl: data['imageUrl'] ?? '',
          gender: data['gender'] ?? '',
          readinessScore: (data['readinessScore'] ?? 0).toDouble(),
          imageBase64: '',
        );
      }).toList();
    });
  }
}
