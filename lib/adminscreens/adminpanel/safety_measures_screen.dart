import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

class SafetyMeasuresScreen extends StatefulWidget {
  const SafetyMeasuresScreen({super.key});

  @override
  State<SafetyMeasuresScreen> createState() => _SafetyMeasuresScreenState();
}

class _SafetyMeasuresScreenState extends State<SafetyMeasuresScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Quick action buttons data
  final List<Map<String, dynamic>> quickActions = [
    {
      'icon': Icons.local_hospital,
      'label': 'Medical',
      'color': const Color(0xFFE53935),
      'number': '108',
    },
    {
      'icon': Icons.local_fire_department,
      'label': 'Fire',
      'color': const Color(0xFFFF6D00),
      'number': '101',
    },
    {
      'icon': Icons.local_police,
      'label': 'Police',
      'color': const Color(0xFF1E88E5),
      'number': '100',
    },
    {
      'icon': Icons.warning_amber_rounded,
      'label': 'Disaster',
      'color': const Color(0xFF7B1FA2),
      'number': '112',
    },
  ];

  // Safety tips data
  final List<Map<String, dynamic>> safetyTips = [
    {
      'icon': Icons.construction,
      'title': 'Wear Safety Gear',
      'description': 'Always wear appropriate PPE on site',
    },
    {
      'icon': Icons.report_problem,
      'title': 'Report Hazards',
      'description': 'Report any unsafe conditions immediately',
    },
    {
      'icon': Icons.emergency,
      'title': 'Know Exits',
      'description': 'Be aware of all emergency exits',
    },
    {
      'icon': Icons.medical_services,
      'title': 'First Aid',
      'description': 'Know the location of first aid kits',
    },
  ];

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final safetyRef = FirebaseFirestore.instance.collection('safety_measures');

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
          centerTitle: true,
          title: const Text(
            "Safety Measures",
            style: TextStyle(
              color: Color.fromARGB(255, 73, 27, 109),
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 0.5,
            ),
          ),
          iconTheme: const IconThemeData(
            color: Color.fromARGB(255, 73, 27, 109),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Header Section
                _buildHeroHeader(),

                const SizedBox(height: 20),

                // SOS Button
                _buildSOSButton(),

                const SizedBox(height: 24),

                // Quick Emergency Actions
                _buildSectionTitle('Quick Emergency Actions'),
                const SizedBox(height: 12),
                _buildQuickActions(),

                const SizedBox(height: 24),

                // Safety Tips Section
                _buildSectionTitle('Daily Safety Tips'),
                const SizedBox(height: 12),
                _buildSafetyTips(),

                const SizedBox(height: 24),

                // Safety Guidelines from Firestore
                _buildSectionTitle('Safety Guidelines'),
                const SizedBox(height: 12),
                _buildFirestoreContent(safetyRef),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade600.withOpacity(0.8),
            Colors.orange.shade600.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.health_and_safety,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Safety Matters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Stay informed and prepared for any emergency situation',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return Center(
      child: GestureDetector(
        onLongPress: () {
          _makePhoneCall('112');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Calling Emergency Services...'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: const LinearGradient(
              colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sos, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SOS Emergency',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Long press to call 112',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Color.fromARGB(255, 73, 27, 109),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: quickActions.length,
        itemBuilder: (context, index) {
          final action = quickActions[index];
          return GestureDetector(
            onTap: () => _makePhoneCall(action['number']),
            child: Container(
              width: 90,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    action['color'].withOpacity(0.8),
                    action['color'].withOpacity(0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: action['color'].withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(action['icon'], color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['label'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    action['number'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSafetyTips() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: safetyTips.length,
        itemBuilder: (context, index) {
          final tip = safetyTips[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7B1FA2).withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF7B1FA2).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        tip['icon'],
                        color: const Color(0xFFFF8F00),
                        size: 22,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      tip['title'],
                      style: const TextStyle(
                        color: Color.fromARGB(255, 73, 27, 109),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip['description'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFirestoreContent(CollectionReference safetyRef) {
    return StreamBuilder<QuerySnapshot>(
      stream: safetyRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 73, 27, 109),
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF7B1FA2).withOpacity(0.1),
            ),
            child: const Center(
              child: Text(
                "No safety guidelines available",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children:
                snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  // Emergency Contacts Tile
                  if (doc.id == "emergency_contacts") {
                    return EnhancedEmergencyContactsTile(
                      data: data,
                      onCall: _makePhoneCall,
                    );
                  }

                  // Normal Safety Measures Tile
                  return EnhancedSafetyExpansionTile(
                    title: data['title'],
                    measures: List<String>.from(data['measures']),
                  );
                }).toList(),
          ),
        );
      },
    );
  }
}

class EnhancedSafetyExpansionTile extends StatelessWidget {
  final String title;
  final List<String> measures;

  const EnhancedSafetyExpansionTile({
    super.key,
    required this.title,
    required this.measures,
  });

  IconData _getIconForTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('fire')) return Icons.local_fire_department;
    if (lowerTitle.contains('electric')) return Icons.electrical_services;
    if (lowerTitle.contains('chemical')) return Icons.science;
    if (lowerTitle.contains('height') || lowerTitle.contains('fall')) {
      return Icons.height;
    }
    if (lowerTitle.contains('machine')) return Icons.precision_manufacturing;
    if (lowerTitle.contains('first aid')) return Icons.medical_services;
    return Icons.security;
  }

  Color _getColorForTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('fire')) return Colors.orange;
    if (lowerTitle.contains('electric')) return Colors.yellow;
    if (lowerTitle.contains('chemical')) return Colors.green;
    if (lowerTitle.contains('height') || lowerTitle.contains('fall')) {
      return Colors.blue;
    }
    if (lowerTitle.contains('machine')) return Colors.grey;
    if (lowerTitle.contains('first aid')) return Colors.red;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getColorForTitle(title);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF7B1FA2).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getIconForTitle(title), color: iconColor, size: 24),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 73, 27, 109),
                fontSize: 16,
              ),
            ),
            iconColor: const Color.fromARGB(255, 73, 27, 109),
            collapsedIconColor: Colors.grey,
            children:
                measures.asMap().entries.map((entry) {
                  final index = entry.key;
                  final measure = entry.value;
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: iconColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            measure,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}

class EnhancedEmergencyContactsTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(String) onCall;

  const EnhancedEmergencyContactsTile({
    super.key,
    required this.data,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final List contacts = data['contacts'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade600.withOpacity(0.3),
            Colors.red.shade900.withOpacity(0.2),
          ],
        ),
        border: Border.all(color: Colors.red.withOpacity(0.4), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.emergency, color: Colors.red, size: 24),
            ),
            title: Text(
              data['title'] ?? 'Emergency Contacts',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 16,
              ),
            ),
            iconColor: Colors.red,
            collapsedIconColor: Colors.red,
            initiallyExpanded: true,
            children:
                contacts.map((contact) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        contact['name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        contact['phone'] ?? '',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                      trailing: GestureDetector(
                        onTap: () => onCall(contact['phone'] ?? ''),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.phone,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}






/*import 'package:flutter/material.dart';

class SafetyMeasuresScreen extends StatelessWidget {
  const SafetyMeasuresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Safety Measures',
          style: TextStyle(
            color: Colors.black,
          ), // Match Admin Dashboard AppBar title color
        ),
        backgroundColor: Colors.white, // Match Admin Dashboard AppBar color
        elevation: 0, // No shadow
        iconTheme: const IconThemeData(
          color: Colors.black,
        ), // Back button color
        centerTitle: true, // Center the title
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security, // Example icon for safety
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'This is the Safety Measures Page',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Manage safety protocols, incidents, and training here!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      // You can add FloatingActionButton for adding new safety protocols or incidents
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Action for adding safety measure/incident
      //   },
      //   child: Icon(Icons.add_alert),
      // ),
    );
  }
}*/