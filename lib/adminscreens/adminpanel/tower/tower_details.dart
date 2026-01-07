import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

/// 🏗️ Admin Side: Shows Tower List + Add/Delete options
class TowerDetailsScreen extends StatelessWidget {
  const TowerDetailsScreen({super.key});

  /// Delete tower from Firestore
  Future<void> _deleteTower(String id, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('towers').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tower deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting tower: $e')));
    }
  }

  /// Add tower dialog
  void _showAddTowerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final idController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            'Add New Tower',
            style: TextStyle(color: Color(0xFF4C0B58)),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tower Name'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(labelText: 'Tower ID'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C0B58),
              ),
              child: const Text('Add Tower'),
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    locationController.text.isNotEmpty &&
                    idController.text.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('towers').add({
                    'tower_name': nameController.text,
                    'location': locationController.text,
                    'tower_id': idController.text,
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tower added successfully')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE1BEE7), // Richer Light Purple
            Color(0xFFD1C4E9), // Deeper Lavender
            Color(0xFFB3E5FC), // Saturated Light Blue
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: Color(0xFF4C0B58)),
          title: const Text(
            'Tower Details (Admin)',
            style: TextStyle(
              color: Color(0xFF4C0B58),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF4C0B58),
          onPressed: () => _showAddTowerDialog(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('towers').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No towers available.'));
            }

            final towers = snapshot.data!.docs;

            return ListView.builder(
              itemCount: towers.length,
              itemBuilder: (context, index) {
                final tower = towers[index];
                final towerName = tower['tower_name'] ?? 'Unnamed Tower';
                final location = tower['location'] ?? 'Unknown Location';
                final towerId = tower['tower_id'] ?? 'N/A';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'lib/assets/images/tower.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      towerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C0B58),
                      ),
                    ),
                    subtitle: Text('Location: $location'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteTower(tower.id, context),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => TowerDetailPage(
                                towerName: towerName,
                                location: location,
                                towerId: towerId,
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
    );
  }
}

/// 📄 Single Tower Details Page
class TowerDetailPage extends StatelessWidget {
  final String towerName;
  final String location;
  final String towerId;

  const TowerDetailPage({
    super.key,
    required this.towerName,
    required this.location,
    required this.towerId,
  });

  /// 🔗 Opens Google Maps for the location
  Future<void> _openMap(String location) async {
    final Uri googleMapUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$location',
    );
    if (await canLaunchUrl(googleMapUrl)) {
      await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE1BEE7), // Richer Light Purple
            Color(0xFFD1C4E9), // Deeper Lavender
            Color(0xFFB3E5FC), // Saturated Light Blue
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: Color(0xFF4C0B58)),
          title: const Text(
            'Tower Details',
            style: TextStyle(
              color: Color(0xFF4C0B58),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Image.asset(
                'lib/assets/images/tower.png',
                height: 220,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Text(
                towerName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C0B58),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _openMap(location),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF4C0B58)),
                    const SizedBox(width: 8),
                    Text(
                      'Location: $location',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.tag, color: Color(0xFF4C0B58)),
                  const SizedBox(width: 8),
                  Text(
                    'Tower ID: $towerId',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Description:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C0B58),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This tower is located in a prime area and built with advanced materials ensuring stability and durability.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Contact Information:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C0B58),
                ),
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(Icons.phone, color: Color(0xFF4C0B58)),
                  SizedBox(width: 8),
                  Text(
                    'Contact: +123 456 7890',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(Icons.email, color: Color(0xFF4C0B58)),
                  SizedBox(width: 8),
                  Text(
                    'Email: info@towercompany.com',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
