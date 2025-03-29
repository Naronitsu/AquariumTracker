import 'package:flutter/material.dart';
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
        builder: (_) => AquariumDetailScreen(aquarium: aquarium),
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
                return Card(
                  child: ListTile(
                    title: Text(aquarium.name),
                    subtitle: Text(
                      '${aquarium.roomLocation} • ${aquarium.volumeInLitres.toStringAsFixed(1)} L',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openAquariumDetail(aquarium),
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
