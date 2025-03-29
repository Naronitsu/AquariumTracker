import 'fish.dart';
import 'water_parameters.dart';

class Aquarium {
  String name;
  String roomLocation;
  double lengthCm;
  double widthCm;
  double heightCm;
  List<Fish> fishInventory;
  WaterParameters? waterParameters;
  String? imagePath; // ✅ ADD THIS LINE

  Aquarium({
    required this.name,
    required this.roomLocation,
    required this.lengthCm,
    required this.widthCm,
    required this.heightCm,
    this.fishInventory = const [],
    this.waterParameters,
    this.imagePath, // ✅ INCLUDE THIS IN CONSTRUCTOR
  });

  double get volumeInCm3 => lengthCm * widthCm * heightCm;

  double get volumeInLitres => volumeInCm3 / 1000;
}

