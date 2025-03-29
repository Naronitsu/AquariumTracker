import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/aquarium.dart';
import '../models/fish.dart';
import '../models/water_parameters.dart';

class AquariumDetailScreen extends StatefulWidget {
  final Aquarium aquarium;
  final Function(Aquarium) onDelete;

  const AquariumDetailScreen({super.key, required this.aquarium, required this.onDelete});

  @override
  State<AquariumDetailScreen> createState() => _AquariumDetailScreenState();
}

class _AquariumDetailScreenState extends State<AquariumDetailScreen> {
  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        widget.aquarium.imagePath = pickedFile.path;
      });
    }
  }

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
              widget.onDelete(widget.aquarium);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addFish() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _qtyController = TextEditingController();
    final _commentController = TextEditingController();
    String _selectedSex = 'Unknown';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Fish'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Fish Name'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _qtyController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final n = int.tryParse(value ?? '');
                    if (n == null || n < 1) return 'Enter valid number';
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedSex,
                  items: ['Male', 'Female', 'Unknown']
                      .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => _selectedSex = val ?? 'Unknown',
                  decoration: const InputDecoration(labelText: 'Sex'),
                ),
                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(labelText: 'Note'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  widget.aquarium.fishInventory.add(
                    Fish(
                      name: _nameController.text,
                      quantity: int.parse(_qtyController.text),
                      sex: _selectedSex,
                      comment: _commentController.text,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editFish(int index, Fish fish) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: fish.name);
    final _qtyController = TextEditingController(text: fish.quantity.toString());
    final _commentController = TextEditingController(text: fish.comment);
    String _selectedSex = fish.sex;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Fish'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Fish Name'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _qtyController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final n = int.tryParse(value ?? '');
                    if (n == null || n < 1) return 'Enter valid number';
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedSex,
                  items: ['Male', 'Female', 'Unknown']
                      .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => _selectedSex = val ?? 'Unknown',
                  decoration: const InputDecoration(labelText: 'Sex'),
                ),
                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(labelText: 'Note'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  widget.aquarium.fishInventory[index] = Fish(
                    name: _nameController.text,
                    quantity: int.parse(_qtyController.text),
                    sex: _selectedSex,
                    comment: _commentController.text,
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editWaterParams() {
    final w = widget.aquarium.waterParameters ?? WaterParameters(
      ph: 0,
      nitrate: 0,
      nitrite: 0,
      ammonia: 0,
      generalHardness: 0,
      temperature: 0,
    );

    final controllers = {
      'pH': TextEditingController(text: w.ph.toString()),
      'Nitrate': TextEditingController(text: w.nitrate.toString()),
      'Nitrite': TextEditingController(text: w.nitrite.toString()),
      'Ammonia': TextEditingController(text: w.ammonia.toString()),
      'GH': TextEditingController(text: w.generalHardness.toString()),
      'Temp': TextEditingController(text: w.temperature.toString()),
    };

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Water Parameters'),
        content: SingleChildScrollView(
          child: Column(
            children: controllers.entries.map((e) => TextField(
              controller: e.value,
              decoration: InputDecoration(labelText: e.key),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                widget.aquarium.waterParameters = WaterParameters(
                  ph: double.tryParse(controllers['pH']!.text) ?? 0,
                  nitrate: double.tryParse(controllers['Nitrate']!.text) ?? 0,
                  nitrite: double.tryParse(controllers['Nitrite']!.text) ?? 0,
                  ammonia: double.tryParse(controllers['Ammonia']!.text) ?? 0,
                  generalHardness: double.tryParse(controllers['GH']!.text) ?? 0,
                  temperature: double.tryParse(controllers['Temp']!.text) ?? 0,
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fish = widget.aquarium.fishInventory;
    final water = widget.aquarium.waterParameters;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.aquarium.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDeleteAquarium,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (widget.aquarium.imagePath != null && File(widget.aquarium.imagePath!).existsSync())
              Image.file(
                File(widget.aquarium.imagePath!),
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
            Text('Room: ${widget.aquarium.roomLocation}'),
            Text(
              'Volume: ${widget.aquarium.volumeInLitres.toStringAsFixed(1)} L',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),
            ListTile(
              title: const Text('Water Parameters'),
              subtitle: water == null
                  ? const Text('Not set')
                  : Text(
                      'pH: ${water.ph}, Temp: ${water.temperature}°C\n'
                      'Nitrate: ${water.nitrate}, Nitrite: ${water.nitrite}\n'
                      'Ammonia: ${water.ammonia}, GH: ${water.generalHardness}',
                    ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editWaterParams,
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Fish Inventory'),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addFish,
              ),
            ),
            ...fish.asMap().entries.map((entry) {
              final index = entry.key;
              final f = entry.value;

              return Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  setState(() {
                    widget.aquarium.fishInventory.removeAt(index);
                  });
                },
                child: ListTile(
                  title: Text(f.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sex: ${f.sex}'),
                      if (f.comment.isNotEmpty) Text('Note: ${f.comment}'),
                    ],
                  ),
                  trailing: Text('x${f.quantity}'),
                  onTap: () => _editFish(index, f),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
