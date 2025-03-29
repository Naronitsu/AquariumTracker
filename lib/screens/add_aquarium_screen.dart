import 'package:flutter/material.dart';
import '../models/aquarium.dart';

class AddAquariumScreen extends StatefulWidget {
  final Function(Aquarium) onAdd;

  const AddAquariumScreen({super.key, required this.onAdd});

  @override
  State<AddAquariumScreen> createState() => _AddAquariumScreenState();
}

class _AddAquariumScreenState extends State<AddAquariumScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roomController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  void _saveAquarium() {
    if (_formKey.currentState!.validate()) {
      final aquarium = Aquarium(
        name: _nameController.text,
        roomLocation: _roomController.text,
        lengthCm: double.parse(_lengthController.text),
        widthCm: double.parse(_widthController.text),
        heightCm: double.parse(_heightController.text),
      );

      widget.onAdd(aquarium);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Aquarium')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Aquarium Name'),
                validator: (value) => value!.isEmpty ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(labelText: 'Room Location'),
                validator: (value) => value!.isEmpty ? 'Enter room location' : null,
              ),
              TextFormField(
                controller: _lengthController,
                decoration: const InputDecoration(labelText: 'Length (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter length' : null,
              ),
              TextFormField(
                controller: _widthController,
                decoration: const InputDecoration(labelText: 'Width (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter width' : null,
              ),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter height' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveAquarium,
                child: const Text('Save Aquarium'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
