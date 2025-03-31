import 'fish.dart';
import 'water_parameters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class Aquarium {
  String id; // Add an id field
  String name;
  String roomLocation;
  double lengthCm;
  double widthCm;
  double heightCm;
  List<Fish> fishInventory; // List of Fish objects
  WaterParameters? waterParameters;
  String? imagePath;
  List<DateTime> feedingTimes; // List of feeding times (DateTime objects)

  // Constructor
  Aquarium({
    required this.id,  // Add the id in the constructor
    required this.name,
    required this.roomLocation,
    required this.lengthCm,
    required this.widthCm,
    required this.heightCm,
    List<Fish>? fishInventory, // Optional parameter
    this.waterParameters,
    this.imagePath,
    List<DateTime>? feedingTimes, // Optional parameter
  })  : fishInventory = fishInventory ?? [], // If null, use an empty list
        feedingTimes = feedingTimes ?? []; // If null, use an empty list

  // Get aquarium volume in cubic centimeters
  double get volumeInCm3 => lengthCm * widthCm * heightCm;

  // Get aquarium volume in liters
  double get volumeInLitres => volumeInCm3 / 1000;

  // Method to add a fish to the inventory
  void addFish(Fish fish) {
    fishInventory.add(fish);
  }

  // Method to remove a fish from the inventory
  void removeFish(Fish fish) {
    fishInventory.remove(fish);
  }

  // Method to get the count of fish of a specific name
  int getFishCount(String fishName) {
    return fishInventory.where((fish) => fish.name == fishName).length;
  }

  // Method to clear all fish in the inventory
  void clearFishInventory() {
    fishInventory.clear();
  }

  // Method to add a feeding time
  void addFeedingTime(DateTime time) {
    feedingTimes.add(time);
  }

  // Method to remove a feeding time
  void removeFeedingTime(DateTime time) {
    feedingTimes.remove(time);
  }

  // Method to clear all feeding times
  void clearFeedingTimes() {
    feedingTimes.clear();
  }

  // Method to convert the Aquarium object to a map
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

  // Factory method to create an Aquarium from Firestore document
  factory Aquarium.fromMap(Map<String, dynamic> data) {
    return Aquarium(
      id: data['id'], // The id is typically provided by Firestore document snapshot
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

