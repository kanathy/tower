import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tower/screens/home/homepage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:tower/screens/history.dart';
import 'package:tower/screens/chatbot.dart';
import 'package:tower/screens/profileset/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:tower/services/notification_service.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isLoading = false;
  final Map<String, bool> _safetyChecklist = {
    'Harness Checked': false,
    'Helmet On': false,
    'Weather Clear': false,
    'Anchor Verified': false,
  };
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String? _currentUsername;
  String? _currentAvatar;

  final List<String> _towerLocations = [
    'Tower 001 - North Hub',
    'Tower 042 - Valley Station',
    'Tower 108 - Ridge Point',
    'Tower 215 - West Coast',
    'Tower 312 - City Center',
    'Tower 504 - Industrial Zone',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('employees')
          .doc(currentUser!.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _currentUsername = (userDoc.data() as Map<String, dynamic>)['username'];
          _currentAvatar = (userDoc.data() as Map<String, dynamic>)['avatarUrl'];
        });
      }
    }
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Tower Location",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4C0B58)),
              ),
              const SizedBox(height: 10),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _towerLocations.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.location_on_rounded, color: Color(0xFF4C0B58)),
                      title: Text(_towerLocations[index]),
                      onTap: () {
                        setState(() {
                          _locationController.text = _towerLocations[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to handle post submission
  Future<void> _submitPost() async {
    String comment = _commentController.text.trim();
    if (comment.isEmpty) {
       showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Required'),
              content: const Text('Please provide a comment'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      String authorName = _currentUsername ?? "User";
      String? authorAvatar = _currentAvatar;
      String authorRole = _roleController.text.trim().isEmpty ? "Official Update" : _roleController.text.trim();

      // 3. Save Post to Firestore
      await FirebaseFirestore.instance.collection('post').add({
        'content': comment,
        'imageUrl': null,
        'location': _locationController.text.trim(),
        'authorId': currentUser!.uid,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'authorRole': authorRole,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
        'commentList': [],
      });

      await NotificationService.addNotification(
        message: 'Your safety post has been uploaded successfully.',
        type: 'post',
        buttonText: 'View Feed',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post uploaded successfully!')),
        );
        setState(() {
          _commentController.clear();
          _roleController.clear();
          _locationController.clear();
          _safetyChecklist.updateAll((key, value) => false);
          _isLoading = false;
        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading post: $e')),
        );
      }
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
          title: const Text(
            'Upload Your Post',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4C0B58),
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4C0B58), size: 20),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Preview Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4C0B58).withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        backgroundImage: (_currentAvatar != null && _currentAvatar!.isNotEmpty)
                            ? NetworkImage(_currentAvatar!)
                            : null,
                        child: (_currentAvatar == null || _currentAvatar!.isEmpty)
                            ? const Icon(Icons.person, color: Color(0xFF4C0B58), size: 30)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUsername ?? "Loading...",
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        const Text(
                          "Safety Update Hub",
                          style: TextStyle(
                            color: Color(0xFF8E319B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              
              // Post Input Area (Glassmorphic)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: "What's the latest safety report?",
                        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 18),
                        border: InputBorder.none,
                      ),
                      maxLines: 4,
                      style: const TextStyle(fontSize: 18, color: Color(0xFF2D3436)),
                    ),
                    const Divider(height: 30),
                    
                    // Optional Role Field
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined, color: Color(0xFF8E319B), size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _roleController,
                            decoration: const InputDecoration(
                              hintText: "Your Current Role (Optional)",
                              hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Site Location Picker (Glassmorphic)
              GestureDetector(
                onTap: _showLocationPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: Color(0xFF4C0B58), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _locationController.text.isEmpty 
                              ? "Add Site" 
                              : _locationController.text,
                          style: TextStyle(
                            fontSize: 16, 
                            color: _locationController.text.isEmpty ? Colors.grey : Color(0xFF2D3436),
                            fontWeight: _locationController.text.isEmpty ? FontWeight.normal : FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Safety Checklist
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  "CRITICAL SAFETY CHECK",
                  style: TextStyle(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: Color(0xFF4C0B58),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _safetyChecklist.keys.map((item) {
                  final isSelected = _safetyChecklist[item]!;
                  return GestureDetector(
                    onTap: () => setState(() => _safetyChecklist[item] = !isSelected),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4C0B58) : Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF4C0B58) : Colors.white,
                          width: 1.5,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: const Color(0xFF4C0B58).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ] : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            size: 16,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF4C0B58))
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4C0B58).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _submitPost,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4C0B58),
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Post to Feed",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
        bottomNavigationBar: CurvedNavigationBar(
          color: const Color(0xffede7f6),
          backgroundColor: Colors.transparent,
          index: 2,
          onTap: (i) {
            if (i == 0) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
            } else if (i == 1) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HistoryPage()));
            } else if (i == 2) {
              // Already on Upload
            } else if (i == 3) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChatBotScreen()));
            } else if (i == 4) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            }
          },
          items: const [
            Icon(Icons.home, size: 30, color: Color(0xFF4C0B58)),
            Icon(Icons.history, size: 30, color: Color(0xFF4C0B58)),
            Icon(Icons.add, size: 30, color: Color(0xFF4C0B58)),
            Icon(Icons.chat, size: 30, color: Color(0xFF4C0B58)),
            Icon(Icons.person, size: 30, color: Color(0xFF4C0B58)),
          ],
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }
}
