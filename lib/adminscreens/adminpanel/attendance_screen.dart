import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance',
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
              Icons.calendar_today, // Example icon for attendance
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'This is the Attendance Page',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Record, track, and manage attendance here!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      // You can add FloatingActionButton for marking attendance, etc.
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Action for marking attendance
      //   },
      //   child: Icon(Icons.check),
      // ),
    );
  }
}
