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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _showAllPosts = false;

  void _handleLike(String postId, List likedBy) async {
    if (currentUser == null) return;
    if (postId.startsWith("default_safety_alert")) return;

    DocumentReference postRef = FirebaseFirestore.instance
        .collection('post')
        .doc(postId);

    if (likedBy.contains(currentUser!.uid)) {
      await postRef.update({
        'likedBy': FieldValue.arrayRemove([currentUser!.uid]),
        'likes': FieldValue.increment(-1),
      });
    } else {
      await postRef.update({
        'likedBy': FieldValue.arrayUnion([currentUser!.uid]),
        'likes': FieldValue.increment(1),
      });
    }
  }

  void _handleComment(String postId, List existingComments) {
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('post')
                      .doc(postId)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final postData =
                    snapshot.data?.data() as Map<String, dynamic>? ?? {};
                final comments = postData['commentList'] as List? ?? [];

                return Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Comments",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 76, 11, 88),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child:
                            comments.isEmpty
                                ? const Center(child: Text("No comments yet"))
                                : ListView.builder(
                                  itemCount: comments.length,
                                  padding: const EdgeInsets.all(16),
                                  itemBuilder: (context, index) {
                                    final c =
                                        comments[index] as Map<String, dynamic>;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 15,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: const Color(
                                              0xfff3e5f5,
                                            ),
                                            backgroundImage:
                                                (c['authorAvatar'] != null &&
                                                        c['authorAvatar']
                                                            .isNotEmpty)
                                                    ? NetworkImage(
                                                      c['authorAvatar'],
                                                    )
                                                    : null,
                                            child:
                                                (c['authorAvatar'] == null ||
                                                        c['authorAvatar']
                                                            .isEmpty)
                                                    ? const Icon(
                                                      Icons.person,
                                                      size: 18,
                                                      color: Color(0xFF8E319B),
                                                    )
                                                    : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  c['authorName'] ?? "User",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  c['text'] ?? "",
                                                  style: const TextStyle(
                                                    fontSize: 14,
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
                      const Divider(height: 1),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                          left: 16,
                          right: 16,
                          top: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: commentController,
                                decoration: InputDecoration(
                                  hintText: "Add a comment...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            CircleAvatar(
                              backgroundColor: const Color(0xFF8E319B),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  if (currentUser == null) return;
                                  if (commentController.text
                                      .trim()
                                      .isNotEmpty) {
                                    final text = commentController.text.trim();
                                    commentController.clear();

                                    DocumentSnapshot uDoc =
                                        await FirebaseFirestore.instance
                                            .collection('employees')
                                            .doc(currentUser!.uid)
                                            .get();

                                    String uName = "User";
                                    String? uAvatar;
                                    if (uDoc.exists) {
                                      uName =
                                          (uDoc.data()
                                              as Map<
                                                String,
                                                dynamic
                                              >)['username'] ??
                                          "User";
                                      uAvatar =
                                          (uDoc.data()
                                              as Map<
                                                String,
                                                dynamic
                                              >)['avatarUrl'];
                                    }

                                    await FirebaseFirestore.instance
                                        .collection('post')
                                        .doc(postId)
                                        .set({
                                          'commentList': FieldValue.arrayUnion([
                                            {
                                              'text': text,
                                              'authorName': uName,
                                              'authorAvatar': uAvatar,
                                              'timestamp':
                                                  DateTime.now()
                                                      .millisecondsSinceEpoch,
                                            },
                                          ]),
                                        }, SetOptions(merge: true));
                                  }
                                },
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
        );
      },
    );
  }

  void _handleShare(String content) {
    Share.share("Check out this Tower Safety update: $content");
  }

  void _handleSend() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Sent to direct message!")));
  }

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
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(2, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ),
        ),

        //label below box
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

  Widget postCard({
    required String postId,
    required String authorName,
    String? authorAvatar,
    required String content,
    String? imageUrl,
    int likes = 0,
    List likedBy = const [],
    Timestamp? timestamp,
    String? authorRole,
  }) {
    final isLiked = currentUser != null && likedBy.contains(currentUser!.uid);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: (authorAvatar != null && authorAvatar.isNotEmpty) 
                    ? NetworkImage(authorAvatar) 
                    : const AssetImage('lib/assets/images/avatar.png') as ImageProvider,
                  radius: 22,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        if (authorRole != null && authorRole.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          const Text("·", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(width: 6),
                          Text(
                            authorRole,
                            style: const TextStyle(
                              color: Color(0xFF636E72),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      timestamp != null 
                        ? "${timestamp.toDate().day}/${timestamp.toDate().month} - ${timestamp.toDate().hour}:${timestamp.toDate().minute}" 
                        : "Official Update",
                      style: const TextStyle(color: Color(0xFFB2BEC3), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.toString().startsWith('http') 
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                    )
                  : Image.asset(
                      imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
              ),
            ],
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Like Icon and Count
                GestureDetector(
                  onTap: () => _handleLike(postId, likedBy),
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        size: 18,
                        color: isLiked ? Colors.blue : const Color(0xFF8E319B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$likes",
                        style: TextStyle(
                          fontSize: 14, 
                          color: isLiked ? Colors.blue : Colors.grey,
                          fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                // Comment
                GestureDetector(
                  onTap: () => _handleComment(postId, []),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.comment,
                        size: 18,
                        color: Color(0xFF8E319B),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Comment",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Share
                GestureDetector(
                  onTap: () => _handleShare(content),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.share,
                        size: 18,
                        color: Color(0xFF8E319B),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Share",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Send
                GestureDetector(
                  onTap: _handleSend,
                  child: Row(
                    children: const [
                      Icon(
                        Icons.send,
                        size: 18,
                        color: Color(0xFF8E319B),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Send",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8E319B),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          "TowerPulse Feed",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4C0B58),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF4C0B58).withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(
                          'lib/assets/images/avatar.png',
                        ),
                      ),
                    ),
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
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_none,
                            color: Color.fromARGB(255, 76, 11, 88),
                            size: 25,
                          ),
                          onPressed: () {
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
                children: [
                  const Text(
                    "Posts",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color.fromARGB(255, 76, 11, 88),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showAllPosts = !_showAllPosts;
                      });
                    },
                    child: Text(
                      _showAllPosts ? "Show Less" : "See All",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 76, 11, 88),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Default Static Post 1 (Always Visible)
              postCard(
                postId: "default_safety_alert_1",
                authorName: "Alex Rivera",
                authorRole: "Site Supervisor",
                content: "Important Safety Alert: Always double-check your full-body harness and lanyard before every climb. Ensure the site anchor points are certified and clearly marked. Safety is our top priority when working on towers! #TowerPulse #SafetyFirst",
                likes: 124,
                likedBy: [],
              ),
              
              if (_showAllPosts) ...[
                // Default Static Post 2
                postCard(
                  postId: "default_safety_alert_2",
                  authorName: "Sarah Chen",
                  authorRole: "Safety Compliance",
                  content: "Weather Warning: High winds expected this afternoon. Please suspend all climbing activities if wind speeds exceed 25mph. Stay safe and stay grounded! 💨🚧 #SafetyAlert #WeatherWatch",
                  likes: 85,
                  likedBy: [],
                ),
                // Default Static Post 3
                postCard(
                  postId: "default_safety_alert_3",
                  authorName: "Marcus Johnson",
                  authorRole: "Equipment Lead",
                  content: "Weekly Gear Check: REMINDER to inspect your pulleys and carabiners for any signs of wear or hairline cracks. If in doubt, swap it out! Don't take chances with your gear. 🛠️👷‍♂️ #SafeGear #TowerMaintenance",
                  likes: 92,
                  likedBy: [],
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('post').orderBy('timestamp', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const SizedBox(); 
                    }
                    
                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        final d = doc.data() as Map<String, dynamic>;
                        return postCard(
                          postId: doc.id,
                          authorName: d['authorName'] ?? "User",
                          authorAvatar: d['authorAvatar'],
                          authorRole: d['authorRole'],
                          content: d['content'] ?? "",
                          imageUrl: d['imageUrl'],
                          likes: d['likes'] ?? 0,
                          likedBy: d['likedBy'] as List? ?? [],
                          timestamp: d['timestamp'] as Timestamp?,
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: CurvedNavigationBar(
          color: const Color(0xffede7f6),
          backgroundColor: Colors.transparent,
          index: 0,
          onTap: (i) {
            if (i == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
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
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
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
