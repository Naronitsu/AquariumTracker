import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  double _length = 0.0;
  double _width = 0.0;
  double _height = 0.0;
  String? _imagePath;
  bool _isLoading = false;

  /// Launch camera and capture aquarium image
  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() => _imagePath = pickedFile.path);
    }
  }

  /// Save aquarium details to Firestore
  Future<void> _saveAquarium() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final aquariumId = FirebaseFirestore.instance.collection('aquariums').doc().id;

      try {
        final aquarium = Aquarium(
          id: aquariumId,
          name: _nameController.text.trim(),
          roomLocation: _roomController.text.trim(),
          lengthCm: _length,
          widthCm: _width,
          heightCm: _height,
          imagePath: _imagePath,
          fishInventory: [],
          feedingTimes: [],
          waterParameters: null,
        );

        await FirebaseFirestore.instance
            .collection('aquariums')
            .doc(aquariumId)
            .set(aquarium.toMap());

        widget.onAdd(aquarium);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add aquarium: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Build the form input field
  Widget _buildTextField({
    required String label,
    required TextInputType keyboardType,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Aquarium')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Aquarium Name'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Please enter a name' : null,
                    ),
                    TextFormField(
                      controller: _roomController,
                      decoration: const InputDecoration(labelText: 'Room Location'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Please enter a room location' : null,
                    ),
                    _buildTextField(
                      label: 'Length (cm)',
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _length = double.tryParse(value) ?? 0.0,
                    ),
                    _buildTextField(
                      label: 'Width (cm)',
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _width = double.tryParse(value) ?? 0.0,
                    ),
                    _buildTextField(
                      label: 'Height (cm)',
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _height = double.tryParse(value) ?? 0.0,
                    ),
                    const SizedBox(height: 16),
                    if (_imagePath != null)
                      Image.file(
                        File(_imagePath!),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    TextButton.icon(
                      onPressed: _takePicture,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                    ),
                    const SizedBox(height: 20),
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