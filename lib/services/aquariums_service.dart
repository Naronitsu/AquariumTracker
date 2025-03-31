import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aquarium_tracker/models/aquarium.dart';

class AquariumService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add aquarium info to Firestore
  Future<void> addAquarium(Aquarium aquarium) async {
    try {
      await _db.collection('aquariums').add(aquarium.toMap());
    } catch (e) {
      print('Error adding aquarium: $e');
    }
  }
}
