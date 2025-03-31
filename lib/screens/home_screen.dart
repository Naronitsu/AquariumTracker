// ✅ FILE 1: home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'add_aquarium_screen.dart' as add_screen;
import 'aquarium_detail_screen.dart' as detail_screen;
import '../models/aquarium.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
    print("Firebase Initialized");
  }

  void _navigateToAddAquariumScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => add_screen.AddAquariumScreen(
          onAdd: _onAquariumAdded,
        ),
      ),
    );
  }

  Future<void> _onAquariumAdded(Aquarium aquarium) async {
    setState(() {});
  }

  void _navigateToDetailScreen(String aquariumId, Map<String, dynamic> aquarium) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => detail_screen.AquariumDetailScreen(
          aquariumId: aquariumId,
          aquarium: aquarium,
          onDelete: _onAquariumDeleted,
          onAdd: _onAquariumAdded,
        ),
      ),
    );
  }

  Future<void> _onAquariumDeleted(String aquariumId) async {
    try {
      await _firestore.collection('aquariums').doc(aquariumId).delete();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete aquarium: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aquarium Tracker')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
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
                    final aquariums = snapshot.data?.docs ?? [];
                    if (aquariums.isEmpty) {
                      return const Center(child: Text('No aquariums available.'));
                    }
                    return ListView.builder(
                      itemCount: aquariums.length,
                      itemBuilder: (context, index) {
                        final aquarium = aquariums[index].data() as Map<String, dynamic>;
                        final aquariumId = aquariums[index].id;
                        return GestureDetector(
                          onTap: () => _navigateToDetailScreen(aquariumId, aquarium),
                          child: ListTile(
                            title: Text(aquarium['name'] ?? 'No Name'),
                            subtitle: Text(aquarium['roomLocation'] ?? 'No Location'),
                            trailing: Text(
                              'L: ${aquarium['lengthCm']} W: ${aquarium['widthCm']} H: ${aquarium['heightCm']} cm',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _navigateToAddAquariumScreen,
                child: const Text("Add Aquarium"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
