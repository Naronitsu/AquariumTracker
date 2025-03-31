
import 'package:cloud_firestore/cloud_firestore.dart';

class Fish {
  String name;
  int quantity;
  String sex;
  String comment;

  Fish({
    required this.name,
    required this.quantity,
    this.sex = 'Unknown',
    this.comment = '',
  });

  // Method to convert Fish object to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'sex': sex,
      'comment': comment,
    };
  }

  // Method to create a Fish object from a Firestore document
  factory Fish.fromMap(Map<String, dynamic> map) {
    return Fish(
      name: map['name'],
      quantity: map['quantity'],
      sex: map['sex'] ?? 'Unknown',
      comment: map['comment'] ?? '',
    );
  }

  // Method to create a Fish object from Firestore document snapshot
  factory Fish.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Fish(
      name: data['name'],
      quantity: data['quantity'],
      sex: data['sex'] ?? 'Unknown',
      comment: data['comment'] ?? '',
    );
  }
}

