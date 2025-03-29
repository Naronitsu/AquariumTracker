import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aquarium Tracker'),
      ),
      body: const Center(
        child: Text('No aquariums yet.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add aquarium screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
