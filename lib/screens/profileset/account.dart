import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tower/screens/history.dart';
import 'package:tower/screens/chatbot.dart';
import 'package:tower/screens/profileset/profile.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:tower/screens/home/homepage.dart';

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
  final TextEditingController _usernameController = TextEditingController(
    text: "yANCHUI",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "yanchui@gmail.com",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "+14987889999",
  );
  final TextEditingController _passwordController = TextEditingController(
    text: "evFTbyVVCd",
  );

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
  void _updateProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      // Perform the profile update logic (e.g., upload to a server)
      print('Profile Updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                  child:
                      _imageFile == null
                          ? const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Color.fromARGB(255, 76, 11, 88),
                          )
                          : ClipOval(
                            child: Image.file(
                              _imageFile!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
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
        backgroundColor: Colors.white,
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
