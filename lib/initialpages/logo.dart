import 'package:flutter/material.dart';
import 'package:tower/initialpages/page1.dart'; // Import the page to navigate to

class LogoScreen extends StatefulWidget {
  @override
  _LogoScreenState createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to Page1 after a 3-second delay
    Future.delayed(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingScreen1(),
        ), // Navigate to Page1
      );
    });
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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image at the top of the screen
            Expanded(
              flex: 3,
              child: Image.asset(
                'lib/assets/images/logo.png', // replace with your image path
                // Ensure the logo covers the available space
              ),
            ),
            const SizedBox(height: 80),
            // Optionally, add any other widgets here
          ],
        ),
      ),
    );
  }
}
