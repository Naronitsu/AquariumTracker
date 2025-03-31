import 'dart:io';
import 'package:flutter/material.dart';
import '../services/notifications_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/aquarium.dart';
import 'add_aquarium_screen.dart';
import 'aquarium_detail_screen.dart';
import 'delete_all_screen.dart';

/// The main screen that displays a list of all aquariums.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Firestore instance to interact with the 'aquariums' collection.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aquarium Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Aquarium',
            onPressed: () => _navigateToAddAquariumScreen(),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete All',
            onPressed: () => _navigateToDeleteAllScreen(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildAquariumList(),
      ),
    );
  }

  /// Navigates to the screen for adding a new aquarium.
  void _navigateToAddAquariumScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAquariumScreen(onAdd: _onAquariumAdded),
      ),
    );
  }

  /// Navigates to the screen for deleting all aquariums.
  void _navigateToDeleteAllScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeleteAllScreen()),
    );
  }

  /// Builds the list of aquariums using a [StreamBuilder].
  Widget _buildAquariumList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('aquariums').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text('No aquariums available.'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final aquarium = Aquarium.fromMap({...data, 'id': doc.id});

            return _buildAquariumCard(aquarium, data);
          },
        );
      },
    );
  }

  /// Builds a card widget displaying aquarium details.
  Widget _buildAquariumCard(Aquarium aquarium, Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: _buildThumbnail(aquarium),
        title: Text(aquarium.name),
        subtitle: Text(
          '${aquarium.roomLocation}\n${aquarium.volumeInLitres.toStringAsFixed(1)} L',
        ),
        trailing: Text(
          '${aquarium.lengthCm}x${aquarium.widthCm}x${aquarium.heightCm} cm\nVolume: ${aquarium.volumeInLitres.toStringAsFixed(1)} L',
        ),
        onTap: () => _openDetailScreen(aquarium, data),
      ),
    );
  }

  /// Builds a thumbnail image for the aquarium if available; otherwise, displays a placeholder icon.
  Widget _buildThumbnail(Aquarium aquarium) {
    if (aquarium.imagePath != null && File(aquarium.imagePath!).existsSync()) {
      return Image.file(
        File(aquarium.imagePath!),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      );
    } else {
      return const Icon(Icons.image_not_supported, size: 40);
    }
  }

  /// Opens the detail screen for the selected [aquarium].
  void _openDetailScreen(Aquarium aquarium, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AquariumDetailScreen(
          aquariumId: aquarium.id,
          aquarium: data,
          onDelete: _onAquariumDeleted,
          onAdd: _onAquariumUpdated,
        ),
      ),
    );
  }

  /// Callback function invoked after a new aquarium is added.
  Future<void> _onAquariumAdded(Aquarium aquarium) async {
    await NotificationsService.showAquariumCreatedNotification(aquarium.name);
    setState(() {}); // Refresh the aquarium list
  }

  /// Callback function invoked after an aquarium is updated.
  Future<void> _onAquariumUpdated(Aquarium updatedAquarium) async {
    await _firestore
        .collection('aquariums')
        .doc(updatedAquarium.id)
        .update(updatedAquarium.toMap());
    setState(() {}); // Refresh the aquarium list
  }

  /// Callback function invoked after an aquarium is deleted.
  Future<void> _onAquariumDeleted(String aquariumId) async {
    await _firestore.collection('aquariums').doc(aquariumId).delete();
    setState(() {}); // Refresh the aquarium list
  }
}
