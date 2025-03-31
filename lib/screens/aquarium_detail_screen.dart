import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/aquarium.dart';
import '../services/notifications_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Detailed screen for a specific aquarium
class AquariumDetailScreen extends StatefulWidget {
  final String aquariumId;
  final Map<String, dynamic> aquarium;
  final Function(String) onDelete;
  final Function(Aquarium) onAdd;

  const AquariumDetailScreen({
    super.key,
    required this.aquariumId,
    required this.aquarium,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  State<AquariumDetailScreen> createState() => _AquariumDetailScreenState();
}

class _AquariumDetailScreenState extends State<AquariumDetailScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();

  Future<void> _updateAquariumData() async {
    await _firebaseFirestore.collection('aquariums').doc(widget.aquariumId).update({
      'feedingTimes': (widget.aquarium['feedingTimes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      'waterParameters': widget.aquarium['waterParameters'],
      'fishInventory': widget.aquarium['fishInventory'],
    });
    widget.onAdd(Aquarium.fromMap(widget.aquarium));
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() => widget.aquarium['imagePath'] = pickedFile.path);

      await _firebaseFirestore.collection('aquariums').doc(widget.aquariumId).update({
        'imagePath': pickedFile.path,
      });

      widget.onAdd(Aquarium.fromMap(widget.aquarium));
    }
  }

  void _setFeedingTime() {
    final int hour = int.tryParse(_hourController.text) ?? 0;
    final int minute = int.tryParse(_minuteController.text) ?? 0;
    widget.aquarium['feedingTimes'] ??= [];

    setState(() {
      widget.aquarium['feedingTimes'].add(DateTime(0, 1, 1, hour, minute));
    });

    NotificationsService.scheduleFeedFishNotification(hour, minute);
    _updateAquariumData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Feeding reminder set for $hour:$minute')),
    );
  }

  void _confirmDeleteAquarium() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Aquarium'),
        content: const Text('Are you sure you want to delete this aquarium?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              widget.onDelete(widget.aquariumId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addOrEditWaterParameters() {
    final Map<String, TextEditingController> controllers = {
      'ph': TextEditingController(),
      'temperature': TextEditingController(),
      'nitrate': TextEditingController(),
      'nitrite': TextEditingController(),
      'ammonia': TextEditingController(),
      'generalHardness': TextEditingController(),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Water Parameters'),
        content: SingleChildScrollView(
          child: Column(
            children: controllers.entries.map((entry) =>
              TextField(
                controller: entry.value,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: entry.key.capitalize()),
              )
            ).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                widget.aquarium['waterParameters'] = controllers.map((key, controller) =>
                  MapEntry(key, double.tryParse(controller.text) ?? 0.0)
                );
              });
              Navigator.pop(context);
              _updateAquariumData();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddFishDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final notesController = TextEditingController();
    String selectedSex = 'Unknown';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Fish'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Fish Name')),
              TextField(controller: quantityController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')),
              DropdownButtonFormField<String>(
                value: selectedSex,
                items: const [
                  DropdownMenuItem(value: 'Unknown', child: Text('Unknown')),
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (value) => selectedSex = value ?? 'Unknown',
                decoration: const InputDecoration(labelText: 'Sex'),
              ),
              TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes (optional)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final newFish = {
                'name': nameController.text.trim(),
                'quantity': int.tryParse(quantityController.text.trim()) ?? 1,
                'sex': selectedSex,
                'notes': notesController.text.trim(),
              };
              setState(() {
                widget.aquarium['fishInventory'] ??= [];
                widget.aquarium['fishInventory'].add(newFish);
              });
              Navigator.pop(context);
              _updateAquariumData();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  double? _calculateVolume() {
    final length = widget.aquarium['lengthCm']?.toDouble();
    final width = widget.aquarium['widthCm']?.toDouble();
    final height = widget.aquarium['heightCm']?.toDouble();
    if (length != null && width != null && height != null) {
      return (length * width * height) / 1000;
    }
    return null;
  }

  void _showFeedingTimeDialog() {
    _hourController.clear();
    _minuteController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Feeding Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _hourController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Hour (24-hour format)'),
            ),
            TextField(
              controller: _minuteController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Minute'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (_hourController.text.isNotEmpty && _minuteController.text.isNotEmpty) {
                _setFeedingTime();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final water = widget.aquarium['waterParameters'];
    final feedingTimes = widget.aquarium['feedingTimes'] ?? [];
    final fishInventory = widget.aquarium['fishInventory'] ?? [];
    final volume = _calculateVolume();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.aquarium['name'] ?? 'Unnamed Aquarium'),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _confirmDeleteAquarium),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (widget.aquarium['imagePath'] != null &&
                File(widget.aquarium['imagePath']).existsSync())
              Image.file(
                File(widget.aquarium['imagePath']),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            _buildDetails(water, volume, feedingTimes, fishInventory),
          ],
        ),
      ),
    );
  }


  Widget _buildDetails(water, double? volume, List feedingTimes, List fishInventory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: _takePicture,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Take Photo'),
        ),
        const SizedBox(height: 8),
        Text('Room: ${widget.aquarium['roomLocation'] ?? 'Unknown'}'),
        Text('Volume: ${volume != null ? volume.toStringAsFixed(1) : 'N/A'} L', style: const TextStyle(fontWeight: FontWeight.bold)),
        const Divider(height: 30),
        ListTile(
          title: const Text('Water Parameters'),
          subtitle: water == null
              ? const Text('Not set')
              : Text('pH: ${water['ph']}, Temp: ${water['temperature']}°C\n'
                  'Nitrate: ${water['nitrate']}, Nitrite: ${water['nitrite']}\n'
                  'Ammonia: ${water['ammonia']}, GH: ${water['generalHardness']}'),
          trailing: IconButton(icon: const Icon(Icons.edit), onPressed: _addOrEditWaterParameters),
        ),
        const Divider(),
        ListTile(
          title: const Text('Fish Inventory'),
          trailing: IconButton(icon: const Icon(Icons.add), onPressed: _showAddFishDialog),
        ),
        ...fishInventory.map<Widget>((fish) => ListTile(
              title: Text('${fish['name']} (${fish['quantity']}, ${fish['sex']})'),
              subtitle: fish['notes']?.isNotEmpty == true ? Text(fish['notes']) : null,
            )),
        const Divider(),
        ListTile(
          title: const Text('Feeding Times'),
          subtitle: feedingTimes.isEmpty
              ? const Text('No feeding times set')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: feedingTimes.map<Widget>((time) {
                    final parsed = time is String ? DateTime.tryParse(time) : (time as DateTime?);
                    return parsed != null
                        ? Text('Feed at ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}')
                        : const Text('Invalid time');
                  }).toList(),
                ),
          trailing: IconButton(icon: const Icon(Icons.add_alarm), onPressed: _showFeedingTimeDialog),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}
