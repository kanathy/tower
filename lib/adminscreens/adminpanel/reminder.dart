import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  Map<String, List<String>> _reminders = {};

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('reminders');
    if (raw != null) {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      setState(() {
        _reminders = decoded.map((k, v) => MapEntry(k, List<String>.from(v)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allEntries =
        _reminders.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Reminders',
          style: TextStyle(
            color: Color(0xFF4C0B58),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Color(0xFF4C0B58)),
      ),
      body:
          allEntries.isEmpty
              ? const Center(
                child: Text(
                  'No reminders added yet.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: allEntries.length,
                itemBuilder: (context, index) {
                  final date = allEntries[index].key;
                  final remindersList = allEntries[index].value;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ExpansionTile(
                      title: Text(
                        date,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4C0B58),
                        ),
                      ),
                      children:
                          remindersList
                              .map(
                                (r) => ListTile(
                                  leading: const Icon(
                                    Icons.event_note,
                                    color: Colors.orange,
                                  ),
                                  title: Text(
                                    r,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  );
                },
              ),
    );
  }
}
