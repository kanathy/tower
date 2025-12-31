import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class TowerListScreen extends StatelessWidget {
  const TowerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3E5F5), Colors.white, Color(0xFFE1F5FE)],
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

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two boxes per row
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: towers.length,
            itemBuilder: (context, index) {
              final tower = towers[index];
              final towerName = tower['tower_name'] ?? 'Unnamed Tower';
              final location = tower['location'] ?? 'Unknown Location';
              final towerId = tower['tower_id'] ?? 'N/A';

              // 🔹 Auto-generate image from Unsplash using tower name or location
              // ✅ More reliable auto-generated image source
              final query = Uri.encodeComponent(
                '$towerName $location tower building',
              );
              final imageUrl =
                  'https://loremflickr.com/400/400/$query'; // always gives random image

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => TowerDetailPage(
                            towerName: towerName,
                            location: location,
                            towerId: towerId,
                            imageUrl: imageUrl,
                          ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F0F9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          imageUrl,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                color: Color(0xFF4C0B58),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'lib/assets/images/tower.png',
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        towerName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF4C0B58),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
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

class TowerDetailPage extends StatelessWidget {
  final String towerName;
  final String location;
  final String towerId;
  final String imageUrl;

  const TowerDetailPage({
    super.key,
    required this.towerName,
    required this.location,
    required this.towerId,
    required this.imageUrl,
  });

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
          colors: [Color(0xFFF3E5F5), Colors.white, Color(0xFFE1F5FE)],
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
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFF4C0B58)),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'lib/assets/images/tower.png',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  );
                },
              ),
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
              'This tower is designed with modern architecture and built using sustainable materials ensuring durability and safety.',
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
            Row(
              children: const [
                Icon(Icons.phone, color: Color(0xFF4C0B58)),
                SizedBox(width: 8),
                Text('Contact: +123 456 7890', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
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
