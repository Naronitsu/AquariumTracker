import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
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
            onPressed: _navigateToAddAquariumScreen,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete All',
            onPressed: _navigateToDeleteAllScreen,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth >= 600;
            return _buildAquariumList(isWideScreen: isWideScreen);
          },
        ),
      ),
    );
  }

  void _navigateToAddAquariumScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAquariumScreen(onAdd: _onAquariumAdded),
      ),
    );
  }

  void _navigateToDeleteAllScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeleteAllScreen()),
    );
  }

  Widget _buildAquariumList({required bool isWideScreen}) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('aquariums').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print(snapshot.error);
          return const Center(child: Text('Something went wrong'));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text('No aquariums available.'));
        }

        return isWideScreen
            ? GridView.builder(
                shrinkWrap: true,
                cacheExtent: 500,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final aquarium = Aquarium.fromMap({
                    ...data,
                    'id': doc.id,
                    'lengthCm': (data['lengthCm'] as num?)?.toDouble() ?? 0.0,
                    'widthCm': (data['widthCm'] as num?)?.toDouble() ?? 0.0,
                    'heightCm': (data['heightCm'] as num?)?.toDouble() ?? 0.0,
                  });
                  return _buildAquariumCard(aquarium, data);
                },
              )
            : ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final aquarium = Aquarium.fromMap({
                    ...data,
                    'id': doc.id,
                    'lengthCm': (data['lengthCm'] as num?)?.toDouble() ?? 0.0,
                    'widthCm': (data['widthCm'] as num?)?.toDouble() ?? 0.0,
                    'heightCm': (data['heightCm'] as num?)?.toDouble() ?? 0.0,
                  });
                  return _buildAquariumCard(aquarium, data);
                },
              );
      },
    );
  }

  Widget _buildAquariumCard(Aquarium aquarium, Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openDetailScreen(aquarium, data),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildThumbnail(aquarium),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(aquarium.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(aquarium.roomLocation, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 2),
                    Text('${aquarium.volumeInLitres.toStringAsFixed(1)} L', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${aquarium.lengthCm}x${aquarium.widthCm}x${aquarium.heightCm} cm', style: Theme.of(context).textTheme.bodySmall),
                  Text('Volume: ${aquarium.volumeInLitres.toStringAsFixed(1)} L', style: Theme.of(context).textTheme.bodySmall),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(Aquarium aquarium) {
    if (kIsWeb || aquarium.imagePath == null) {
      return const Icon(Icons.image_not_supported, size: 60);
    }

    try {
      final file = File(aquarium.imagePath!);
      if (file.existsSync()) {
        return Image.file(file, width: 60, height: 60, fit: BoxFit.cover);
      } else {
        return const Icon(Icons.image_not_supported, size: 60);
      }
    } catch (_) {
      return const Icon(Icons.image_not_supported, size: 60);
    }
  }

  void _openDetailScreen(Aquarium aquarium, Map<String, dynamic> data) {
    try {
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
    } catch (e, stack) {
      debugPrint('Failed to open AquariumDetailScreen: $e\n$stack');
    }
  }

  Future<void> _onAquariumAdded(Aquarium aquarium) async {
    await NotificationsService.showAquariumCreatedNotification(aquarium.name);
    setState(() {});
  }

  Future<void> _onAquariumUpdated(Aquarium updatedAquarium) async {
    await _firestore.collection('aquariums').doc(updatedAquarium.id).update(updatedAquarium.toMap());
    setState(() {});
  }

  Future<void> _onAquariumDeleted(String aquariumId) async {
    await _firestore.collection('aquariums').doc(aquariumId).delete();
    setState(() {});
  }
}