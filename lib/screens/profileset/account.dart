import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tower/screens/history.dart';
import 'package:tower/screens/chatbot.dart';
import 'package:tower/screens/profileset/profile.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:tower/screens/home/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: const Color(0xFF5A189A)),
      home: const AccountPage(),
    );
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  File? _imageFile;
  String? _currentAvatarUrl;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('employees')
            .doc(currentUser!.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _usernameController.text = data['username'] ?? '';
            _emailController.text = currentUser!.email ?? '';
            _phoneController.text = data['phone'] ?? '';
            _currentAvatarUrl = data['avatarUrl'];
            // Don't pre-fill password for security
          });
        } else {
           // If no doc exists, at least fill email from Auth
           setState(() {
             _emailController.text = currentUser!.email ?? '';
           });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Function to pick an image
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  // Function to handle profile update
  Future<void> _updateProfile() async {
    print("DEBUG: _updateProfile called");
    if (_formKey.currentState?.validate() ?? false) {
      print("DEBUG: Form is valid");
      if (currentUser == null) {
        print("DEBUG: currentUser is null");
        return;
      }
      print("DEBUG: currentUser is ${currentUser!.uid}");

      try {
        String? imageUrl;
        if (_imageFile != null) {
          print("DEBUG: Attempting to upload image...");
          imageUrl = await _uploadImage(_imageFile!);
          print("DEBUG: Image uploaded, url: $imageUrl");
        } else {
          print("DEBUG: No image file selected to upload.");
        }

        Map<String, dynamic> updateData = {
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
        };

        if (imageUrl != null) {
          updateData['avatarUrl'] = imageUrl;
        }

        print("DEBUG: Updating Firestore with data: $updateData");
        await FirebaseFirestore.instance
            .collection('employees')
            .doc(currentUser!.uid)
            .set(updateData, SetOptions(merge: true));
        print("DEBUG: Firestore update successful");

        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Profile Updated Successfully!')),
           );
        }
      } catch (e) {
        print("DEBUG: Error caught: $e");
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error updating profile: $e')),
           );
        }
      }
    } else {
       print("DEBUG: Form validation failed");
    }
  }

  Future<String> _uploadImage(File image) async {
    print("DEBUG: _uploadImage called");
    try {
      if (!image.existsSync()) {
        throw Exception("Selected file does not exist locally!");
      }

      Uint8List fileBytes = await image.readAsBytes();
      print("DEBUG: File size: ${fileBytes.length} bytes");

      if (fileBytes.isEmpty) {
         throw Exception("File is empty (0 bytes).");
      }

      // Using default bucket automatically configured in google-services.json
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${currentUser!.uid}.jpg');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': image.path},
      );

      print("DEBUG: Starting upload (putData) to ${storageRef.fullPath}");
      final UploadTask uploadTask = storageRef.putData(fileBytes, metadata);

      final TaskSnapshot snapshot = await uploadTask;

      print("DEBUG: Upload completed. State: ${snapshot.state}");
      
      if (snapshot.state == TaskState.success) {
        // Small delay to ensure consistency
        await Future.delayed(const Duration(milliseconds: 500));
        return await storageRef.getDownloadURL();
      } else {
        throw Exception('Upload task finished with state: ${snapshot.state}');
      }
    } catch (e) {
      print("DEBUG: _uploadImage exception: $e");
      throw Exception('Image upload failed: $e');
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4C0B58)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF4C0B58),
            ),
          ),
          centerTitle: true,
        ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile picture section with CircleAvatar
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
                          ? NetworkImage(_currentAvatarUrl!) as ImageProvider
                          : null),
                  child: (_imageFile == null && (_currentAvatarUrl == null || _currentAvatarUrl!.isEmpty))
                      ? const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Color.fromARGB(255, 76, 11, 88),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Username field>>
              _buildLabelAndTextField(
                "Username",
                _usernameController,
                Icons.person_outline,
              ),
              const SizedBox(height: 20),

              // Email field
              _buildLabelAndTextField(
                "Email Address",
                _emailController,
                Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              // Phone number field
              _buildLabelAndTextField(
                "Phone Number",
                _phoneController,
                Icons.phone_outlined,
              ),
              const SizedBox(height: 20),

              // Password field
              _buildLabelAndTextField(
                "Password",
                _passwordController,
                Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 40),

              // Update button
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4C0B58),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: Color(0xffede7f6),
        backgroundColor: Colors.transparent,
        index: 0, // Select the initial tab index
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          } else if (i == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HistoryPage()),
            );
          } else if (i == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AccountPage()),
            );
          } else if (i == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => ChatBotScreen()),
            );
          } else if (i == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => ProfileScreen()),
            );
          }
        },
        items: [
          Icon(Icons.home, size: 30, color: Color.fromARGB(255, 76, 11, 88)),
          Icon(Icons.history, size: 30, color: Color.fromARGB(255, 76, 11, 88)),
          Icon(Icons.add, size: 30, color: Color.fromARGB(255, 76, 11, 88)),
          Icon(Icons.chat, size: 30, color: Color.fromARGB(255, 76, 11, 88)),
          Icon(Icons.person, size: 30, color: Color.fromARGB(255, 76, 11, 88)),
        ],
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
      ),
      ),
    );
  }

  // Helper function to build the label and text field
  Widget _buildLabelAndTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF4C0B58),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: "Enter $label",
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "$label is required";
            }
            return null;
          },
        ),
      ],
    );
  }
}
