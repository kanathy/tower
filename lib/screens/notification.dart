import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:rxdart/rxdart.dart';

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
  late Stream<List<Map<String, dynamic>>> _mergedStream;

  @override
  void initState() {
    super.initState();
    _mergedStream = _createMergedStream();
  }

  Stream<List<Map<String, dynamic>>> _createMergedStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    final notificationsStream = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .snapshots();

    final attendanceStream = FirebaseFirestore.instance
        .collection('attendance')
        .where('userId', isEqualTo: user.uid)
        .snapshots();

    final postStream = FirebaseFirestore.instance
        .collection('post')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();

    // Map each stream to a List<Map<String, dynamic>> and combine them
    return Rx.combineLatest3(
      notificationsStream,
      attendanceStream,
      postStream,
      (QuerySnapshot notifs, QuerySnapshot attendance, QuerySnapshot posts) {
        final List<Map<String, dynamic>> allItems = [];

        for (var doc in notifs.docs) {
          final data = doc.data() as Map<String, dynamic>;
          allItems.add({
            ...data,
            'type': 'notification',
            'sortDate': data['createdAt'] ?? Timestamp.now(),
            'displayMessage': data['message'] ?? '',
            'displayButton': data['buttonText'] ?? 'View',
          });
        }

        for (var doc in attendance.docs) {
          final data = doc.data() as Map<String, dynamic>;
          allItems.add({
            ...data,
            'type': 'attendance',
            'sortDate': data['createdAt'] ?? Timestamp.now(),
            'displayMessage': 'Attendance marked for ${data['site']} on ${data['date']}',
            'displayButton': 'History',
          });
        }

        for (var doc in posts.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final bool isOwnPost = data['authorId'] == user.uid;
          
          allItems.add({
            ...data,
            'type': 'post',
            'sortDate': data['timestamp'] ?? Timestamp.now(),
            'displayMessage': isOwnPost 
                ? 'Your safety post from ${data['location']} was uploaded.'
                : '${data['authorName'] ?? 'Someone'} shared a new safety update from ${data['location']}.',
            'displayButton': 'View Feed',
          });
        }

        // Sort by date descending
        allItems.sort((a, b) {
          final Timestamp t1 = a['sortDate'] as Timestamp;
          final Timestamp t2 = b['sortDate'] as Timestamp;
          return t2.compareTo(t1);
        });

        return allItems;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE1BEE7), // Richer Light Purple
            Color(0xFFD1C4E9), // Deeper Lavender
            Color(0xFFB3E5FC), // Saturated Light Blue
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // ---------------- APP BAR ----------------
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
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
        ),

        // ---------------- BODY ----------------
        body:
            user == null
                ? const Center(
                  child: Text(
                    'Please login to see notifications',
                    style: TextStyle(fontSize: 14),
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _showAll = !_showAll;
                            });
                          },
                          child: Text(
                            _showAll ? 'Show Less' : 'See All',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),

                      // ----------- NOTIFICATION LIST -----------
                      Expanded(
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                          stream: _mergedStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error fetching notifications\n${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text('No activity available'),
                              );
                            }

                            final items = _showAll ? snapshot.data! : snapshot.data!.take(10).toList();

                            return ListView.separated(
                              itemCount: items.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final data = items[index];

                                final Timestamp? ts =
                                    data['sortDate'] as Timestamp?;
                                final String time =
                                    ts == null
                                        ? ''
                                        : DateFormat(
                                          'MMM dd, yyyy • hh:mm a',
                                        ).format(ts.toDate());

                                IconData activityIcon = Icons.notifications;
                                if (data['type'] == 'attendance') activityIcon = Icons.event_available;
                                if (data['type'] == 'post') activityIcon = Icons.post_add;

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F3F9),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        activityIcon,
                                        color: const Color(0xFF4C0B58),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['displayMessage'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              time,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  // Logic for viewing details
                                                  if (data['type'] == 'attendance') {
                                                    Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryPage()));
                                                  } else if (data['type'] == 'post') {
                                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFF4C0B58,
                                                  ),
                                                  minimumSize: const Size(
                                                    110,
                                                    36,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                ),
                                                child: Text(
                                                  data['displayButton'] ?? 'View',
                                                  style: const TextStyle(
                                                    fontSize: 12,
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
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

        // ---------------- BOTTOM NAV ----------------
        bottomNavigationBar: CurvedNavigationBar(
          color: const Color(0xffede7f6),
          backgroundColor: Colors.transparent,
          index: 0,
          animationDuration: const Duration(milliseconds: 300),
          items: const [
            Icon(Icons.home, size: 30, color: Color(0xFF4C0B58)),
            Icon(Icons.history, size: 30, color: Color(0xFF4C0B58)),
            Icon(Icons.add, size: 30, color: Color(0xFF4C0B58)),
            Icon(Icons.chat, size: 30, color: Color(0xFF4C0B58)),
            Icon(Icons.person, size: 30, color: Color(0xFF4C0B58)),
          ],
          onTap: (i) {
            final pages = [
              HomePage(),
              HistoryPage(),
              UploadPage(),
              ChatBotScreen(),
              ProfileScreen(),
            ];
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => pages[i]),
            );
          },
        ),
      ),
    );
  }
}
