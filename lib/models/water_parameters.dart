import 'package:cloud_firestore/cloud_firestore.dart';

class WaterParameters {
  double ph;
  double nitrate;
  double nitrite;
  double ammonia;
  double generalHardness;
  double temperature;

  WaterParameters({
    required this.ph,
    required this.nitrate,
    required this.nitrite,
    required this.ammonia,
    required this.generalHardness,
    required this.temperature,
  });

  // Method to convert WaterParameters object to a map
  Map<String, dynamic> toMap() {
    return {
      'ph': ph,
      'nitrate': nitrate,
      'nitrite': nitrite,
      'ammonia': ammonia,
      'generalHardness': generalHardness,
      'temperature': temperature,
    };
  }

  // Method to create WaterParameters from Firestore document
  factory WaterParameters.fromMap(Map<String, dynamic> data) {
    return WaterParameters(
      ph: data['ph'] ?? 0.0,
      nitrate: data['nitrate'] ?? 0.0,
      nitrite: data['nitrite'] ?? 0.0,
      ammonia: data['ammonia'] ?? 0.0,
      generalHardness: data['generalHardness'] ?? 0.0,
      temperature: data['temperature'] ?? 0.0,
    );
  }

  bool isPhUnsafe(double value) => value < 6.0 || value > 8.0;
  bool isNitrateUnsafe(double value) => value > 40;
  bool isNitriteUnsafe(double value) => value > 1;
  bool isAmmoniaUnsafe(double value) => value > 0.25;
  bool isGhUnsafe(double value) => value < 4 || value > 12;
  bool isTempUnsafe(double value) => value < 22 || value > 28;
}
