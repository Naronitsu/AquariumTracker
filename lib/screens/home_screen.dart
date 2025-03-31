import 'dart:io';

import 'package:flutter/material.dart';
import '../services/notifications_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/aquarium.dart';
import 'add_aquarium_screen.dart';
import 'aquarium_detail_screen.dart';
import 'delete_all_screen.dart';

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
      appBar: AppBar(title: const Text('Aquarium Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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

                      // Include the document ID when building the model
                      final aquarium = Aquarium.fromMap({...data, 'id': doc.id});

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: aquarium.imagePath != null &&
                                  File(aquarium.imagePath!).existsSync()
                              ? Image.file(
                                  File(aquarium.imagePath!),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image_not_supported, size: 40),
                          title: Text(aquarium.name),
                          subtitle: Text(
                            '${aquarium.roomLocation}\n${aquarium.volumeInLitres.toStringAsFixed(1)} L',
                          ),
                          trailing: Text(
                            '${aquarium.lengthCm}x${aquarium.widthCm}x${aquarium.heightCm} cm\nVolume: ${aquarium.volumeInLitres.toStringAsFixed(1)} L',
                          ),
                          onTap: () {
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
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Aquarium"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddAquariumScreen(onAdd: _onAquariumAdded),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text("Delete All"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeleteAllScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAquariumAdded(Aquarium aquarium) async {
    await NotificationsService.showAquariumCreatedNotification(aquarium.name);
    setState(() {}); // Refresh list
  }

  Future<void> _onAquariumUpdated(Aquarium updatedAquarium) async {
    await _firestore
        .collection('aquariums')
        .doc(updatedAquarium.id)
        .update(updatedAquarium.toMap());
    setState(() {});
  }

  Future<void> _onAquariumDeleted(String aquariumId) async {
    await _firestore.collection('aquariums').doc(aquariumId).delete();
    setState(() {});
  }
}
