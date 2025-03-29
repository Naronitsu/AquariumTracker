import 'package:flutter/material.dart';
import 'dart:io';

import '../models/aquarium.dart';
import 'add_aquarium_screen.dart';
import 'aquarium_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Aquarium> _aquariums = [];

  void _addAquarium(Aquarium newAquarium) {
    setState(() {
      _aquariums.add(newAquarium);
    });
  }

  void _navigateToAddAquarium() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAquariumScreen(onAdd: _addAquarium),
      ),
    );
  }

  void _openAquariumDetail(Aquarium aquarium) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AquariumDetailScreen(
          aquarium: aquarium,
          onDelete: (deletedAquarium) {
            setState(() {
              _aquariums.remove(deletedAquarium);
            });
            Navigator.pop(context); // Close detail screen
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aquarium Tracker'),
      ),
      body: _aquariums.isEmpty
          ? const Center(
              child: Text('No aquariums yet. Tap + to add one.'),
            )
          : ListView.builder(
              itemCount: _aquariums.length,
              itemBuilder: (context, index) {
                final aquarium = _aquariums[index];

                return Dismissible(
                  key: ValueKey(aquarium),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    setState(() {
                      _aquariums.removeAt(index);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${aquarium.name} deleted')),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      leading: aquarium.imagePath != null &&
                              File(aquarium.imagePath!).existsSync()
                          ? Image.file(
                              File(aquarium.imagePath!),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_outlined),
                      title: Text(aquarium.name),
                      subtitle: Text(
                        '${aquarium.roomLocation} • ${aquarium.volumeInLitres.toStringAsFixed(1)} L',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openAquariumDetail(aquarium),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddAquarium,
        child: const Icon(Icons.add),
      ),
    );
  }
}
