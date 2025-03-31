import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a fish species or group in the aquarium
class Fish {
  String name;
  int quantity;
  String sex; // Can be 'Male', 'Female', or 'Unknown'
  String comment;

  Fish({
    required this.name,
    required this.quantity,
    this.sex = 'Unknown',
    this.comment = '',
  });

  /// Convert Fish object into a map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'sex': sex,
      'comment': comment,
    };
  }

  /// Create a Fish object from a map (e.g., from Firestore)
  factory Fish.fromMap(Map<String, dynamic> map) {
    return Fish(
      name: map['name'],
      quantity: map['quantity'],
      sex: map['sex'] ?? 'Unknown',
      comment: map['comment'] ?? '',
    );
  }

  /// Create a Fish object from a Firestore document snapshot
  factory Fish.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Fish.fromMap(data);
  }
}