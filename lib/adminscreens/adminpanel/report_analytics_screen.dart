import 'package:flutter/material.dart';

class ReportAnalyticsScreen extends StatelessWidget {
  const ReportAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report Analytics',
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
              Icons.bar_chart, // Example icon for analytics
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'This is the Reports & Analytics Page',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Display your key performance indicators and reports here!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      // You can add FloatingActionButton for generating new reports, etc.
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Action for generating report
      //   },
      //   child: Icon(Icons.download),
      // ),
    );
  }
}
