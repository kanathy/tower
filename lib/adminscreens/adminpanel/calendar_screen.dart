import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<String>> _reminders = {};

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

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

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reminders', jsonEncode(_reminders));
  }

  void _addReminder(DateTime day, String reminder) {
    final key = _dateKey(day);
    if (_reminders[key] == null) {
      _reminders[key] = [];
    }
    _reminders[key]!.add(reminder);
    _saveReminders();
    setState(() {});
  }

  void _deleteReminder(DateTime day, int index) {
    final key = _dateKey(day);
    _reminders[key]?.removeAt(index);
    if (_reminders[key]?.isEmpty ?? false) {
      _reminders.remove(key);
    }
    _saveReminders();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selectedKey =
        _selectedDay != null ? _dateKey(_selectedDay!) : _dateKey(_focusedDay);
    final selectedReminders = _reminders[selectedKey] ?? [];

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
          centerTitle: true,
          leading: const BackButton(color: Color(0xFF4C0B58)),
          title: const Text(
            'Calendar',
            style: TextStyle(
              color: Color(0xFF4C0B58),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Color.fromARGB(255, 73, 27, 109),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDay == null
                              ? 'No date selected'
                              : 'Reminders for ${_dateKey(_selectedDay!)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed:
                            _selectedDay == null
                                ? null
                                : () => _showAddReminderDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C0B58),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      selectedReminders.isEmpty
                          ? const Center(
                            child: Text('No reminders for this date'),
                          )
                          : ListView.builder(
                            itemCount: selectedReminders.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(selectedReminders[index]),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    _deleteReminder(_selectedDay!, index);
                                  },
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Add Reminder'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Enter your reminder',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty && _selectedDay != null) {
                    _addReminder(_selectedDay!, text);
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}
