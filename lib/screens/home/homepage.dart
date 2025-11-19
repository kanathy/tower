import 'package:flutter/material.dart';
import 'package:tower/screens/task.dart';
import 'package:tower/screens/home/attendance.dart';
import 'package:tower/screens/notification.dart';
import 'package:tower/screens/history.dart';
import 'package:tower/screens/chatbot.dart';
import 'package:tower/screens/profileset/profile.dart';
import 'package:tower/screens/upload.dart';
import 'package:tower/screens/towers.dart';
import 'package:tower/screens/heartrate.dart';
import 'package:tower/screens/o2.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget buildFeatureCard(
    String label,
    String imagePath,
    Color pillColor, {
    VoidCallback? onTap,
    double size = 110,
  }) {
    final card = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.purple.withOpacity(0.2), // Feedback splash effect
          highlightColor: Colors.purple.withOpacity(0.1), // Feedback on tap
          child: Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              color: const Color(0xffD1DAED),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.4,
                  ), // Darker shadow with more opacity
                  blurRadius: 15, // Increased blur for a softer, larger shadow
                  offset: const Offset(
                    2,
                    6,
                  ), // Keeps the shadow offset as before
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
    return onTap != null ? GestureDetector(onTap: onTap, child: card) : card;
  }

  Widget postCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('lib/assets/images/avatar.png'),
                  radius: 22,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Thomas Blake · 1 st",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Usage-6 Month",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      "16 h ·",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Just used a skin detection app to check a spot on my skin — and it showed signs that could be related to skin cancer. Skin cancer is a disease where abnormal skin cells grow uncontrollably...",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween, // Ensure even space between items
                  children: [
                    // Like Icon and Count
                    Row(
                      children: const [
                        Icon(
                          Icons.thumb_up,
                          size: 18,
                          color: const Color(
                            0xFF8E319B,
                          ), // Custom color for the Like icon
                        ),
                        SizedBox(width: 8), // Space between icon and count
                        Text(
                          "77",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    // Space between Like and Comment
                    SizedBox(
                      width: 25,
                    ), // Increased space between Like and Comment
                    // Comment Icon and Text
                    Row(
                      children: const [
                        Icon(
                          Icons.comment,
                          size: 18,
                          color: const Color(
                            0xFF8E319B,
                          ), // Same color for comment icon
                        ),
                        SizedBox(width: 8), // Space between icon and text
                        Text(
                          "Comment",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    // Space between Comment and Share
                    SizedBox(
                      width: 25,
                    ), // Increased space between Comment and Share
                    // Share Icon and Text
                    Row(
                      children: const [
                        Icon(
                          Icons.share,
                          size: 18,
                          color: const Color(
                            0xFF8E319B,
                          ), // Same color for Share icon
                        ),
                        SizedBox(width: 8), // Space between icon and text
                        Text(
                          "Share",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    // Space between Share and Send
                    SizedBox(width: 35), // Space between Share and Send
                    // Send Icon and Text
                    Row(
                      children: const [
                        Icon(
                          Icons.send,
                          size: 18,
                          color: const Color(
                            0xFF8E319B,
                          ), // Same color for Send icon
                        ),
                        SizedBox(width: 8), // Space between icon and text
                        Text(
                          "Send",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget featureGrid(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildFeatureCard(
                "Attendance",
                "lib/assets/images/attendance.png",
                const Color(0xFF6D3AF3),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SafetyChecklistScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 20),
              buildFeatureCard(
                "Tasks",
                "lib/assets/images/task.png",
                const Color(0xFF6436A6),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TaskToDoScreen()),
                  );
                },
              ),
              const SizedBox(width: 20),
              buildFeatureCard(
                "Towers",
                "lib/assets/images/tower.png",
                const Color(0xFF8E319B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TowerListScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildFeatureCard(
                "Heart Rate",
                "lib/assets/images/heartrate.png",
                const Color(0xFF5945A3),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HeartRatePage()),
                  );
                },
              ),
              const SizedBox(width: 30),
              buildFeatureCard(
                "Oxygen Level",
                "lib/assets/images/oxygen.png",
                const Color(0xFF6237A0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BloodOxygenPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(88),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 18,
              right: 18,
              top: 14,
              bottom: 4,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Greeting
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Hi Sam!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 76, 11, 88),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Welcome to TowerPulse',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                // RIGHT: Avatar + Notification
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigate to Profile Screen when Avatar is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProfileScreen()),
                        );
                      },
                      child: CircleAvatar(
                        radius: 31,
                        backgroundImage: AssetImage(
                          'lib/assets/images/avatar.png',
                        ),
                      ),
                    ),
                    SizedBox(height: 7),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffede7f6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
        child: ListView(
          children: [
            // Search bar with weather and notification inside left
            Row(
              children: [
                // Weather Icon and Label (inside the bar, left)
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  margin: EdgeInsets.only(right: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wb_cloudy_outlined,
                        color: Color.fromARGB(255, 76, 11, 88),
                        size: 25,
                      ),
                      const SizedBox(width: 8), // Added space between icons
                      // Notification Icon (inside the same Row)
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Color.fromARGB(255, 76, 11, 88),
                          size: 25,
                        ),
                        onPressed: () {
                          // Navigate to NotificationScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NotificationScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Search Field (expanded)
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search Here",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            featureGrid(context),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Posts",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color.fromARGB(255, 76, 11, 88),
                  ),
                ),
                Text(
                  "See All",
                  style: TextStyle(
                    color: Color.fromARGB(255, 76, 11, 88),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            postCard(),
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
