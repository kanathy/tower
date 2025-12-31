import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:tower/screens/chatbot.dart';
import 'package:tower/screens/history.dart';
import 'package:tower/screens/home/homepage.dart';
import 'package:tower/screens/login/createnewpassword.dart';
import 'package:tower/screens/login/signup.dart';
import 'package:tower/screens/profileset/account.dart';
import 'package:tower/screens/profileset/edit_profile.dart';
import 'package:tower/screens/profileset/feedback.dart';
import 'package:tower/screens/profileset/settings.dart';
import 'package:tower/screens/upload.dart';

void main() {
  runApp(const ProfileApp());
}

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3E5F5),
            Colors.white,
            Color(0xFFE1F5FE),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'My Profile',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4C0B58),
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF4C0B58)),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            ),
          ),
        ),
      body: currentUser == null
          ? const Center(child: Text("Please log in to view profile"))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('employees')
                  .doc(currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading profile"));
                }

                final userData = snapshot.data?.data() as Map<String, dynamic>?;
                final username = userData?['username'] ?? "User";
                final email = userData?['email'] ?? currentUser!.email ?? "";
                final avatarUrl = userData?['avatarUrl'];

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // 🔹 Profile Header with Glow
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4C0B58).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.transparent, // transparent to show glow if needed, or Theme color
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                          ? NetworkImage(avatarUrl) as ImageProvider
                          : const AssetImage('lib/assets/images/avatar.png'),
                    ),
                  ),
                ],
              ),
            ),
                      const SizedBox(height: 16),
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : const Color(0xFF4C0B58),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[400] 
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 🔹 Profile Options List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ProfileMenuWidget(
                    title: "Edit Profile",
                    icon: Icons.edit,
                    onPress: () {
                      // Navigate to Edit Profile (if exists) or Account Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AccountPage()),
                      );
                    },
                  ),
                  ProfileMenuWidget(
                    title: "Account Settings",
                    icon: Icons.settings,
                    onPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),
                  ProfileMenuWidget(
                    title: "Give Feedback",
                    icon: Icons.feedback,
                    onPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FeedbackPage()),
                      );
                    },
                  ),
                  ProfileMenuWidget(
                    title: "Change Password",
                    icon: Icons.lock,
                    onPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateNewPasswordScreen(),
                        ),
                      );
                    },
                  ),
                  ProfileMenuWidget(
                    title: "Rate Us",
                    icon: Icons.star_rate_rounded,
                    onPress: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const RateUsDialog();
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  ProfileMenuWidget(
                    title: "Logout",
                    icon: Icons.logout,
                    textColor: Colors.red,
                    endIcon: false,
                    onPress: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const LogoutDialog();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ); // Closes SingleChildScrollView
    },
  ), // Closes StreamBuilder

      // 🔹 Bottom Navigation Bar
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.white.withOpacity(0.9),
        backgroundColor: Colors.transparent,
        index: 4, // Profile Tab Index
        onTap: (i) {
          if (i == index) return;
          if (i == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (i == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HistoryPage()),
            );
          } else if (i == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => UploadPage()),
            );
          } else if (i == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => ChatBotScreen()),
            );
          } else if (i == 4) {
            // Already on Profile
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

  final int index = 4;
}

/// 🔹 Reusable Menu Widget
class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C0B58).withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        onTap: onPress,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFF4C0B58).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF4C0B58)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor ?? const Color(0xFF4C0B58),
          ),
        ),
        trailing: endIcon
            ? Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
              )
            : null,
      ),
    );
  }
}

// 🔹 Rate Us Dialog
class RateUsDialog extends StatefulWidget {
  const RateUsDialog({super.key});

  @override
  State<RateUsDialog> createState() => _RateUsDialogState();
}

class _RateUsDialogState extends State<RateUsDialog> {
  int _rating = 4;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Rate Your Experience",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4C0B58),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C0B58),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text("Submit", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}

// 🔹 Logout Dialog
class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text("Logout"),
      content: const Text("Are you sure you want to log out?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
            // Navigate to Create Account (Signup) page
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
              (route) => false,
            );
          },
          child: const Text("Logout", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
