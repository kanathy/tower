import 'package:flutter/material.dart';
import 'package:tower/screens/history.dart';
import 'package:tower/screens/chatbot.dart';
import 'package:tower/screens/upload.dart';
import 'package:tower/screens/home/homepage.dart';
import 'package:tower/screens/profileset/account.dart'; // Assuming the Account page
import 'package:tower/screens/profileset/feedback.dart'; // Assuming the Feedback page
import 'package:tower/screens/profileset/edit_profile.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; // Assuming the Edit Profile page
import 'package:tower/screens/login/signup.dart'; // Assuming the Signup page
import 'package:tower/screens/login/createnewpassword.dart'; // Assuming CreateNewPasswordScreen
import 'package:tower/screens/profileset/account.dart';

void main() {
  runApp(ProfileApp());
}

class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ProfileScreen());
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 76, 11, 88),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 76, 11, 88),
          ),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Profile Picture
            CircleAvatar(
              radius: 70,
              backgroundColor: Color.fromARGB(255, 76, 11, 88),
              child: CircleAvatar(
                radius: 65,
                backgroundImage: AssetImage(
                  'lib/assets/images/avatar.png',
                ), // Replace with your image asset
              ),
            ),
            SizedBox(height: 10),
            Text(
              'John Kevin',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text('+91 1234567890', style: TextStyle(color: Colors.grey)),
            Text('abcd123@gmail.com', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 30),

            // Profile Options
            ProfileOption(
              icon: Icons.account_circle,
              label: 'Account',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AccountPage()),
                );
              },
            ),
            ProfileOption(
              icon: Icons.feedback,
              label: 'Feedback',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FeedbackPage()),
                );
              },
            ),
            ProfileOption(
              icon: Icons.location_on,
              label: 'Location',
              onTap: () {},
            ),
            ProfileOption(
              icon: Icons.star,
              label: 'Rate Us',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const RateUsDialog();
                  },
                );
              },
            ),
            ProfileOption(
              icon: Icons.lock,
              label: 'Change Password',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateNewPasswordScreen()),
                );
              },
            ),
            ProfileOption(
              icon: Icons.exit_to_app,
              label: 'Logout',
              onTap: () {
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
              MaterialPageRoute(builder: (_) => UploadPage()),
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
          Icon(
            Icons.home,
            size: 30,
            color: Color.fromARGB(255, 76, 11, 88), // Selected color
          ),
          Icon(
            Icons.history,
            size: 30,
            color: Color.fromARGB(255, 76, 11, 88), // Unselected color
          ),
          Icon(
            Icons.add,
            size: 30,
            color: Color.fromARGB(255, 76, 11, 88), // Unselected color
          ),
          Icon(
            Icons.chat,
            size: 30,
            color: Color.fromARGB(255, 76, 11, 88), // Unselected color
          ),
          Icon(
            Icons.person,
            size: 30,
            color: Color.fromARGB(255, 76, 11, 88), // Unselected color
          ),
        ],
        animationCurve: Curves.easeInOut, // Optional for animation effect
        animationDuration: const Duration(
          milliseconds: 300,
        ), // Optional for animation effect
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function onTap;

  ProfileOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5, // Added elevation for box effect
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Color.fromARGB(255, 76, 11, 88)),
        title: Text(
          label,
          style: const TextStyle(color: Color.fromARGB(255, 76, 11, 88)),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color.fromARGB(255, 76, 11, 88),
        ),
        onTap: () => onTap(),
      ),
    );
  }
}

// Dialog for Rate Us
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                // You can handle submit logic here
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4B1C7D),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Rate Us',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 35,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// Dialog for Logout
class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Logout'),
          onPressed: () {
            Navigator.of(context).pop();
            // Redirect to Signup Page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CreateAccountScreen()),
            );
          },
        ),
      ],
    );
  }
}

// Create New Password Screen
