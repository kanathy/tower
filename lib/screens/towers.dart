import 'package:flutter/material.dart';
import 'dart:ui';
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
              final List<Color> cardColors = [
                const Color(0xFFF3E5F5), // Light Purple
                const Color(0xFFE8F5E9), // Light Green
                const Color(0xFFE1F5FE), // Light Blue
                const Color(0xFFFFF3E0), // Light Orange
                const Color(0xFFFFEBEE), // Light Red
                const Color(0xFFF1F8E9), // Light Lime
                const Color(0xFFE0F2F1), // Light Teal
                const Color(0xFFFCE4EC), // Light Pink
              ];

              return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two boxes per row
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85, // Adjusted to prevent vertical overflow
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
                    color: cardColors[index % cardColors.length],
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          towerName,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF4C0B58),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          location,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE1BEE7),
              Color(0xFFD1C4E9),
              Color(0xFFB3E5FC),
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Sliver Header with Parallax Image
            SliverAppBar(
              expandedHeight: 300.0,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: const Color(0xFF4C0B58),
              leading: const BackButton(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  towerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'lib/assets/images/tower.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Inner shadow for better text visibility
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black54, Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
              ),
            ),

            // Content Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Bar (Glassmorphic)
                    _buildGlassCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(Icons.tag_rounded, "ID", towerId),
                          Container(width: 1, height: 30, color: const Color(0xFF4C0B58).withOpacity(0.1)),
                          _buildStatItem(Icons.location_on_rounded, "Loc", location.split(',')[0]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description Section
                    const Text(
                      "About this Tower",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4C0B58),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "This tower is a state-of-the-art infrastructure designed with modern architecture. It serves as a critical node in our network, built with sustainable materials ensuring maximum durability, high performance, and worker safety.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions / Contact Section
                    const Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C0B58),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.map_rounded,
                            label: "Navigate",
                            color: Colors.blue.shade600,
                            onTap: () => _openMap(location),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.phone_rounded,
                            label: "Contact",
                            color: const Color(0xFF4C0B58),
                            onTap: () {
                              // Action for contact
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Contact Details List
                    _buildGlassCard(
                      child: Column(
                        children: [
                          _buildContactRow(Icons.email_outlined, "info@towerpulse.com"),
                          const Divider(),
                          _buildContactRow(Icons.phone_outlined, "+123 456 7890"),
                          const Divider(),
                          _buildContactRow(Icons.business_outlined, "TowerPulse Infrastructure Ltd."),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF4C0B58), size: 24),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4C0B58))),
      ],
    );
  }

  Widget _buildActionCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4C0B58)),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87))),
        ],
      ),
    );
  }
}
