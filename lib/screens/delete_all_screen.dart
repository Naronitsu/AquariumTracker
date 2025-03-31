import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteAllScreen extends StatelessWidget {
  const DeleteAllScreen({super.key});

  Future<void> _deleteAllAquariums(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('aquariums');

    final snapshot = await collection.get();
    final batch = firestore.batch();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All aquariums deleted')),
      );
      Navigator.pop(context); // Go back after deletion
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete All Aquariums')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to delete all aquariums?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => _deleteAllAquariums(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
