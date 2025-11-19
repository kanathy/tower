import 'package:flutter/material.dart';

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
}
