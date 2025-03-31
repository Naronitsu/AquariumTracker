import 'fish.dart';
import 'water_parameters.dart';

/// Represents a single aquarium and all its properties
class Aquarium {
  String id;
  String name;
  String roomLocation;
  double lengthCm;
  double widthCm;
  double heightCm;
  List<Fish> fishInventory;
  WaterParameters? waterParameters;
  String? imagePath;
  List<DateTime> feedingTimes;

  Aquarium({
    required this.id,
    required this.name,
    required this.roomLocation,
    required this.lengthCm,
    required this.widthCm,
    required this.heightCm,
    List<Fish>? fishInventory,
    this.waterParameters,
    this.imagePath,
    List<DateTime>? feedingTimes,
  })  : fishInventory = fishInventory ?? [],
        feedingTimes = feedingTimes ?? [];

  /// Volume in cubic centimeters
  double get volumeInCm3 => lengthCm * widthCm * heightCm;

  /// Volume in litres (1,000 cm^3 = 1 L)
  double get volumeInLitres => volumeInCm3 / 1000;

  /// Alternative volume calculation (redundant, kept for clarity/testing)
  double calculateVolumeLitres() => volumeInLitres;

  /// Fish inventory helpers
  void addFish(Fish fish) => fishInventory.add(fish);
  void removeFish(Fish fish) => fishInventory.remove(fish);
  int getFishCount(String fishName) =>
      fishInventory.where((fish) => fish.name == fishName).length;
  void clearFishInventory() => fishInventory.clear();

  /// Feeding schedule helpers
  void addFeedingTime(DateTime time) => feedingTimes.add(time);
  void removeFeedingTime(DateTime time) => feedingTimes.remove(time);
  void clearFeedingTimes() => feedingTimes.clear();

  /// Convert this object into a map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'roomLocation': roomLocation,
      'lengthCm': lengthCm,
      'widthCm': widthCm,
      'heightCm': heightCm,
      'fishInventory': fishInventory.map((fish) => fish.toMap()).toList(),
      'waterParameters': waterParameters?.toMap(),
      'imagePath': imagePath,
      'feedingTimes': feedingTimes.map((e) => e.toIso8601String()).toList(),
    };
  }

  /// Create an Aquarium object from a Firebase map
  factory Aquarium.fromMap(Map<String, dynamic> data) {
    return Aquarium(
      id: data['id'],
      name: data['name'],
      roomLocation: data['roomLocation'],
      lengthCm: data['lengthCm'],
      widthCm: data['widthCm'],
      heightCm: data['heightCm'],
      fishInventory: (data['fishInventory'] as List)
          .map((fish) => Fish.fromMap(fish))
          .toList(),
      waterParameters: data['waterParameters'] != null
          ? WaterParameters.fromMap(data['waterParameters'])
          : null,
      imagePath: data['imagePath'],
      feedingTimes: (data['feedingTimes'] as List)
    .map((e) => e is DateTime ? e : DateTime.parse(e))
    .toList(),
    );
  }
}