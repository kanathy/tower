import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tower/adminscreens/adminpanel/employee/employee_details_screen.dart';
import 'package:tower/adminscreens/adminpanel/report_analytics_screen.dart';
import 'package:tower/adminscreens/adminpanel/safety_measures_screen.dart';
import 'package:tower/adminscreens/adminpanel/attendance_screen.dart';
import 'package:tower/adminscreens/adminpanel/calendar_screen.dart';
import 'package:tower/adminscreens/adminpanel/feedback_screen.dart';
import 'package:tower/adminscreens/adminpanel/notification.dart';
import 'package:tower/adminscreens/adminpanel/staffs_screen.dart';

class FeedbackAdminPage extends StatefulWidget {
  const FeedbackAdminPage({super.key});

  @override
  State<FeedbackAdminPage> createState() => _FeedbackAdminPageState();
}

class _FeedbackAdminPageState extends State<FeedbackAdminPage> {
  List<Map<String, dynamic>> _feedbackList = [];

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString('user_feedbacks');

    if (storedData != null) {
      final List decoded = jsonDecode(storedData);
      setState(() {
        _feedbackList = List<Map<String, dynamic>>.from(decoded);
      });
    }
  }

  Future<void> _deleteFeedback(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _feedbackList.removeAt(index);
    await prefs.setString('user_feedbacks', jsonEncode(_feedbackList));
    setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Feedbacks',
          style: TextStyle(
            color: Color(0xFF4B1C7D),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF4B1C7D)),
      ),
      body:
          _feedbackList.isEmpty
              ? const Center(child: Text('No feedbacks available'))
              : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _feedbackList.length,
                itemBuilder: (context, index) {
                  final fb = _feedbackList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.person,
                        color: Color(0xFF4B1C7D),
                      ),
                      title: Text(fb['name'] ?? 'Anonymous'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fb['feedback'] ?? ''),
                          if (fb['emoji'] != null)
                            Text('Rating: ${fb['emoji']}'),
                          if (fb['time'] != null)
                            Text(
                              'Submitted at: ${fb['time'].substring(0, 16)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteDialog(index);
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Feedback'),
            content: const Text(
              'Are you sure you want to delete this feedback?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  _deleteFeedback(index);
                  Navigator.pop(ctx);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
