import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/aquarium.dart';
import '../services/notifications_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  _AquariumDetailScreenState createState() => _AquariumDetailScreenState();
}

class _AquariumDetailScreenState extends State<AquariumDetailScreen> {
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();

  // Save the updated aquarium to Firestore
  Future<void> _updateAquariumData() async {
    await _firestore.collection('aquariums').doc(widget.aquariumId).update({
      'feedingTimes': (widget.aquarium['feedingTimes'] as List)
          .map((e) => (e is DateTime) ? e.toIso8601String() : e.toString())
          .toList(),
      'waterParameters': widget.aquarium['waterParameters'],
      'fishInventory': widget.aquarium['fishInventory'],
    });

    widget.onAdd(Aquarium.fromMap(widget.aquarium));
  }

  // Pick an image and update Firestore
  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        widget.aquarium['imagePath'] = pickedFile.path;
      });

      await _firestore.collection('aquariums').doc(widget.aquariumId).update({
        'imagePath': pickedFile.path,
      });

      widget.onAdd(Aquarium.fromMap(widget.aquarium));
    }
  }

  // Add a feeding time and update Firestore
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

  // Confirm and delete aquarium
  void _confirmDeleteAquarium() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Aquarium'),
        content: const Text('Are you sure you want to delete this aquarium?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
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

  // Dialog to add/edit water parameters
  void _showWaterParameterDialog() {
    final phController = TextEditingController();
    final tempController = TextEditingController();
    final nitrateController = TextEditingController();
    final nitriteController = TextEditingController();
    final ammoniaController = TextEditingController();
    final ghController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Water Parameters'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: phController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'pH')),
              TextField(controller: tempController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Temperature (°C)')),
              TextField(controller: nitrateController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nitrate')),
              TextField(controller: nitriteController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nitrite')),
              TextField(controller: ammoniaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ammonia')),
              TextField(controller: ghController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'General Hardness (GH)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                widget.aquarium['waterParameters'] = {
                  'ph': double.tryParse(phController.text) ?? 0,
                  'temperature': double.tryParse(tempController.text) ?? 0,
                  'nitrate': double.tryParse(nitrateController.text) ?? 0,
                  'nitrite': double.tryParse(nitriteController.text) ?? 0,
                  'ammonia': double.tryParse(ammoniaController.text) ?? 0,
                  'generalHardness': double.tryParse(ghController.text) ?? 0,
                };
              });

              Navigator.pop(context); // Close dialog first
              _updateAquariumData(); // Sync to Firestore
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Dialog to add a fish to inventory
  void _showAddFishDialog() {
    final nameController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Fish'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Fish Name')),
            TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes (optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final newFish = {
                'name': nameController.text.trim(),
                'notes': notesController.text.trim(),
              };

              setState(() {
                widget.aquarium['fishInventory'] ??= [];
                widget.aquarium['fishInventory'].add(newFish);
              });

              Navigator.pop(context); // Close dialog
              _updateAquariumData(); // Sync to Firestore
            },
            child: const Text('Add'),
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
            // Image preview
            if (widget.aquarium['imagePath'] != null &&
                File(widget.aquarium['imagePath']).existsSync())
              Image.file(
                File(widget.aquarium['imagePath']),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            TextButton.icon(
              onPressed: _takePicture,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
            ),
            const SizedBox(height: 8),

            // Basic info
            Text('Room: ${widget.aquarium['roomLocation'] ?? 'Unknown'}'),
            Text(
              'Volume: ${widget.aquarium['volumeInLitres'] ?? 'N/A'} L',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),

            // Water Parameters
            ListTile(
              title: const Text('Water Parameters'),
              subtitle: water == null
                  ? const Text('Not set')
                  : Text(
                      'pH: ${water['ph']}, Temp: ${water['temperature']}°C\n'
                      'Nitrate: ${water['nitrate']}, Nitrite: ${water['nitrite']}\n'
                      'Ammonia: ${water['ammonia']}, GH: ${water['generalHardness']}',
                    ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _showWaterParameterDialog,
              ),
            ),
            const Divider(),

            // Fish Inventory
            ListTile(
              title: const Text('Fish Inventory'),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _showAddFishDialog,
              ),
            ),
            ...fishInventory.map<Widget>((fish) {
              return ListTile(
                title: Text(fish['name'] ?? 'Unnamed Fish'),
                subtitle: Text(fish['notes'] ?? ''),
              );
            }),

            const Divider(),

            // Feeding Times
            ListTile(
              title: const Text('Feeding Times'),
              subtitle: feedingTimes.isEmpty
                  ? const Text('No feeding times set')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: feedingTimes.map<Widget>((time) {
                        DateTime? parsed;
                        if (time is String) {
                          parsed = DateTime.tryParse(time);
                        } else if (time is DateTime) {
                          parsed = time;
                        }
                        if (parsed != null) {
                          final h = parsed.hour.toString().padLeft(2, '0');
                          final m = parsed.minute.toString().padLeft(2, '0');
                          return Text('Feed at $h:$m');
                        } else {
                          return const Text('Invalid time');
                        }
                      }).toList(),
                    ),
              trailing: IconButton(
                icon: const Icon(Icons.add_alarm),
                onPressed: () {
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
                            if (_hourController.text.isNotEmpty &&
                                _minuteController.text.isNotEmpty) {
                              _setFeedingTime();
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
