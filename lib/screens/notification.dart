import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:tower/screens/history.dart';
import 'package:tower/screens/chatbot.dart';
import 'package:tower/screens/profileset/profile.dart';
import 'package:tower/screens/upload.dart';
import 'package:tower/screens/home/homepage.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _showAll = false;

  final List<Map<String, String>> _all = [
    {
      'message':
          'You are logged in. See your Safety Checklist & mark your attendance',
      'date': 'April 2023',
      'button': 'View Checklist',
    },
    {
      'message': 'Your tasks are assigned today',
      'date': 'April 2023',
      'button': 'View Task',
    },
  ]..addAll(
    List.generate(
      6,
      (_) => {
        'message':
            'You are logged in. See your Safety Checklist & mark your attendance',
        'date': 'April 2023',
        'button': 'View Checklist',
      },
    ),
  );

  List<Map<String, String>> get _visible =>
      _showAll ? _all : _all.take(5).toList();

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

        // ───────── AppBar ─────────
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4C0B58)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Notifications',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF4C0B58),
            ),
          ),
          centerTitle: true,
        ),

        // ───────── Body ─────────
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _showAll = !_showAll),
                  child: Text(
                    _showAll ? 'Show Less' : 'See All',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Notification List
              Expanded(
                child: ListView.separated(
                  itemCount: _visible.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final item = _visible[index];
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F3F9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(
                              Icons.notifications_none,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['message']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['date']!,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(130, 36),
                                      backgroundColor: const Color(0xFF4C0B58),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      item['button']!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // ───────── Bottom Nav ─────────
        bottomNavigationBar: CurvedNavigationBar(
          color: const Color(0xffede7f6),
          backgroundColor: Colors.transparent,
          index: 0,
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
          items: const [
            Icon(Icons.home, size: 30, color: Color.fromARGB(255, 76, 11, 88)),
            Icon(
              Icons.history,
              size: 30,
              color: Color.fromARGB(255, 76, 11, 88),
            ),
            Icon(Icons.add, size: 30, color: Color.fromARGB(255, 76, 11, 88)),
            Icon(Icons.chat, size: 30, color: Color.fromARGB(255, 76, 11, 88)),
            Icon(
              Icons.person,
              size: 30,
              color: Color.fromARGB(255, 76, 11, 88),
            ),
          ],
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }
}
