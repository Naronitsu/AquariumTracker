import 'package:flutter/material.dart';
import '../models/aquarium.dart';
import '../models/fish.dart';
import '../models/water_parameters.dart';

class AquariumDetailScreen extends StatefulWidget {
  final Aquarium aquarium;

  const AquariumDetailScreen({super.key, required this.aquarium});

  @override
  State<AquariumDetailScreen> createState() => _AquariumDetailScreenState();
}

class _AquariumDetailScreenState extends State<AquariumDetailScreen> {
  void _addFish() {
    final _nameController = TextEditingController();
    final _qtyController = TextEditingController();
    final _commentController = TextEditingController();
    String _selectedSex = 'Unknown';
    final List<String> _sexOptions = ['Male', 'Female', 'Unknown'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Fish'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Fish Name'),
                ),
                TextField(
                  controller: _qtyController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedSex,
                  items: _sexOptions.map((sex) {
                    return DropdownMenuItem(
                      value: sex,
                      child: Text(sex),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _selectedSex = value ?? 'Unknown';
                  },
                  decoration: const InputDecoration(labelText: 'Sex'),
                ),
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(labelText: 'Comments / Notes'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  widget.aquarium.fishInventory.add(
                    Fish(
                      name: _nameController.text,
                      quantity: int.tryParse(_qtyController.text) ?? 1,
                      sex: _selectedSex,
                      comment: _commentController.text,
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editWaterParams() {
    final params = widget.aquarium.waterParameters ??
        WaterParameters(
          ph: 0,
          nitrate: 0,
          nitrite: 0,
          ammonia: 0,
          generalHardness: 0,
          temperature: 0,
        );

    final _controllers = {
      'pH': TextEditingController(text: params.ph.toString()),
      'Nitrate': TextEditingController(text: params.nitrate.toString()),
      'Nitrite': TextEditingController(text: params.nitrite.toString()),
      'Ammonia': TextEditingController(text: params.ammonia.toString()),
      'GH': TextEditingController(text: params.generalHardness.toString()),
      'Temp': TextEditingController(text: params.temperature.toString()),
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Water Parameters'),
          content: SingleChildScrollView(
            child: Column(
              children: _controllers.entries.map((entry) {
                return TextField(
                  controller: entry.value,
                  decoration: InputDecoration(labelText: entry.key),
                  keyboardType: TextInputType.number,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  widget.aquarium.waterParameters = WaterParameters(
                    ph: double.tryParse(_controllers['pH']!.text) ?? 0,
                    nitrate: double.tryParse(_controllers['Nitrate']!.text) ?? 0,
                    nitrite: double.tryParse(_controllers['Nitrite']!.text) ?? 0,
                    ammonia: double.tryParse(_controllers['Ammonia']!.text) ?? 0,
                    generalHardness: double.tryParse(_controllers['GH']!.text) ?? 0,
                    temperature: double.tryParse(_controllers['Temp']!.text) ?? 0,
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fish = widget.aquarium.fishInventory;
    final water = widget.aquarium.waterParameters;

    return Scaffold(
      appBar: AppBar(title: Text(widget.aquarium.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Room: ${widget.aquarium.roomLocation}'),
            const SizedBox(height: 10),
            Text(
              'Volume: ${widget.aquarium.volumeInLitres.toStringAsFixed(1)} L '
              '(${widget.aquarium.volumeInCm3.toStringAsFixed(0)} cm³)',
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
            ...fish.map((f) => ListTile(
                  title: Text(f.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sex: ${f.sex}'),
                      if (f.comment.isNotEmpty) Text('Note: ${f.comment}'),
                    ],
                  ),
                  trailing: Text('x${f.quantity}'),
                )),
          ],
        ),
      ),
    );
  }
}
