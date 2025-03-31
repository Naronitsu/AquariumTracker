import 'fish.dart';
import 'water_parameters.dart';
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

  double get volumeInCm3 => lengthCm * widthCm * heightCm;
  double get volumeInLitres => volumeInCm3 / 1000;

  // ✅ New volume method
  double calculateVolumeLitres() {
    return (lengthCm * widthCm * heightCm) / 1000;
  }

  void addFish(Fish fish) => fishInventory.add(fish);
  void removeFish(Fish fish) => fishInventory.remove(fish);
  int getFishCount(String fishName) =>
      fishInventory.where((fish) => fish.name == fishName).length;
  void clearFishInventory() => fishInventory.clear();

  void addFeedingTime(DateTime time) => feedingTimes.add(time);
  void removeFeedingTime(DateTime time) => feedingTimes.remove(time);
  void clearFeedingTimes() => feedingTimes.clear();

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
          .map((e) => DateTime.parse(e))
          .toList(),
    );
  }
}


