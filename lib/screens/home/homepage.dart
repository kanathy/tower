import 'package:flutter/material.dart';
import 'dart:ui';
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
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:tower/services/notification_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tower/services/weather_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _showAllPosts = false;
  StreamSubscription? _heartRateSub;
  StreamSubscription? _o2Sub;
  StreamSubscription? _postSub;
  Position? _currentPosition;
  Map<String, dynamic>? _weatherData;
  final WeatherService _weatherService = WeatherService();
  bool _isLoadingWeather = false;
  String? _weatherError;

  @override
  void initState() {
    super.initState();
    _setupHealthListeners();
    _setupPostListener();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _heartRateSub?.cancel();
    _o2Sub?.cancel();
    _postSub?.cancel();
    super.dispose();
  }

  // ---------------- Location Permission ----------------
  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;

    if (status.isDenied) {
      if (await Permission.location.request().isGranted) {
        print("Location permission granted");
        _getCurrentLocation();
      } else {
        print("Location permission denied");
      }
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else if (status.isGranted) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _weatherError = "Location services are disabled in settings.";
          _isLoadingWeather = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _weatherError = "Location permission denied.";
            _isLoadingWeather = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _weatherError = "Location permission permanently denied. Please enable in settings.";
          _isLoadingWeather = false;
        });
        return;
      }

      // Try last known position first for speed
      Position? position = await Geolocator.getLastKnownPosition();
      
      if (position != null) {
        print('Using last known position: ${position.latitude}, ${position.longitude}');
        setState(() => _currentPosition = position);
        _fetchWeather(position.latitude, position.longitude);
      }

      // Then get fresh position
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5), // Quicker timeout
      );

      setState(() {
        _currentPosition = position;
      });

      _fetchWeather(position!.latitude, position!.longitude);
      print('Current fresh location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('DEBUG: Location fetch failed: $e');
      if (_currentPosition == null) {
        setState(() {
          _weatherError = "Could not get location. Ensure GPS is on and try again.";
          _isLoadingWeather = false;
        });
      }
    }
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
    });
    final data = await _weatherService.fetchWeather(lat, lon);
    setState(() {
      _weatherData = data;
      _isLoadingWeather = false;
      if (data == null) {
        _weatherError = "Failed to load weather data.";
      }
    });
  }

  void _showWeatherDialog() {
    if (_weatherData == null) {
      String msg = _isLoadingWeather ? "Fetching weather..." : (_weatherError ?? "Weather data unavailable. Tap to retry.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _getCurrentLocation,
          ),
        ),
      );
      if (!_isLoadingWeather) _getCurrentLocation();
      return;
    }

    final temp = _weatherData!['main']['temp'];
    final condition = _weatherData!['weather'][0]['main'];
    final description = _weatherData!['weather'][0]['description'];
    final humidity = _weatherData!['main']['humidity'];
    final windSpeed = _weatherData!['wind']['speed'];
    final city = _weatherData!['name'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.wb_cloudy_rounded, color: Color(0xFF4C0B58)),
            const SizedBox(width: 10),
            Text("Weather in $city", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text("$temp°C", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF4C0B58))),
                  Text(condition, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Text(description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            _buildWeatherDetail(Icons.water_drop, "Humidity", "$humidity%"),
            _buildWeatherDetail(Icons.air, "Wind Speed", "${windSpeed} m/s"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Color(0xFF4C0B58))),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4C0B58)),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _setupHealthListeners() {
    final database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://towersafety-56937-default-rtdb.asia-southeast1.firebasedatabase.app',
    );

    // Heart Rate Listener
    _heartRateSub = database.ref('Device/BPM').onValue.listen((event) {
      final val = event.snapshot.value;
      if (val is int) {
        if (val > 100) {
          NotificationService.addNotification(
            message:
                'Warning: High Heart Rate detected ($val bpm). Please rest.',
            type: 'health_alert',
            buttonText: 'Check Pulse',
          );
        } else if (val < 60 && val > 0) {
          NotificationService.addNotification(
            message: 'Warning: Low Heart Rate detected ($val bpm).',
            type: 'health_alert',
            buttonText: 'Check Pulse',
          );
        }
      }
    });

    // Oxygen Level Listener
    _o2Sub = database.ref('Device/SpO2').onValue.listen((event) {
      final val = event.snapshot.value;
      if (val is int && val < 95 && val > 0) {
        NotificationService.addNotification(
          message:
              'Warning: Low Oxygen level detected ($val%). Ensure proper ventilation.',
          type: 'health_alert',
          buttonText: 'Check O2',
        );
      }
    });

    // Fall Detection Listener (Assuming path Device/Fall)
    database.ref('Device/Fall').onValue.listen((event) {
      final val = event.snapshot.value;
      if (val == true) {
        NotificationService.addNotification(
          message: 'EMERGENCY: Fall detected! Are you okay?',
          type: 'emergency',
          buttonText: 'I am Okay',
        );
      }
    });
  }

  void _setupPostListener() {
    // Listen for new posts from others
    _postSub = FirebaseFirestore.instance
        .collection('post')
        .where('timestamp', isGreaterThan: Timestamp.now())
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data() as Map<String, dynamic>;
              if (data['authorId'] != currentUser?.uid) {
                NotificationService.addNotification(
                  message:
                      '${data['authorName'] ?? 'Someone'} shared a new safety update.',
                  type: 'feed_update',
                  buttonText: 'View Feed',
                );
              }
            }
          }
        });
  }

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
            color: pillColor.withOpacity(0.9), // Slightly more solid for better contrast
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4C0B58), // Dark purple for high contrast
              fontWeight: FontWeight.bold, // Bolder for better visibility
              fontSize: 13,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      (authorAvatar != null && authorAvatar.isNotEmpty)
                          ? NetworkImage(authorAvatar)
                          : const AssetImage('lib/assets/images/avatar.png')
                              as ImageProvider,
                  radius: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              authorName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF2D3436),
                              ),
                            ),
                          ),
                          if (authorRole != null && authorRole.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            const Text(
                              "·",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                authorRole,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF636E72),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        timestamp != null
                            ? "${timestamp.toDate().day}/${timestamp.toDate().month} - ${timestamp.toDate().hour}:${timestamp.toDate().minute}"
                            : "Official Update",
                        style: const TextStyle(
                          color: Color(0xFFB2BEC3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(content, style: const TextStyle(fontSize: 14)),
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    imageUrl.toString().startsWith('http')
                        ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.error),
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
                          fontWeight:
                              isLiked ? FontWeight.bold : FontWeight.normal,
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
                      Icon(Icons.comment, size: 18, color: Color(0xFF8E319B)),
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
                      Icon(Icons.share, size: 18, color: Color(0xFF8E319B)),
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
                      Icon(Icons.send, size: 18, color: Color(0xFF8E319B)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Services",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color.fromARGB(255, 76, 11, 88),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildFeatureCard(
              "Attendance",
              'lib/assets/images/attendance.png',
              const Color(0xFFF3E5F5), // Light purple
              size: 100,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SafetyChecklistScreen()),
                );
              },
            ),
            buildFeatureCard(
              "Tasks",
              'lib/assets/images/task.png',
              const Color(0xFFE8F5E9), // Light green
              size: 100,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TaskToDoScreen()),
                );
              },
            ),
            buildFeatureCard(
              "Towers",
              'lib/assets/images/tower.png',
              const Color(0xFFE1F5FE), // Light blue
              size: 100,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TowerListScreen()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildFeatureCard(
              "Heart Rate",
              'lib/assets/images/heartrate.png',
              const Color(0xFFFFF3E0), // Light orange
              size: 100,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HeartRatePage()),
                );
              },
            ),
            const SizedBox(width: 16),
            buildFeatureCard(
              "Oxygen Level",
              'lib/assets/images/oxygen.png',
              const Color(0xFFFFEBEE), // Light red
              size: 100,
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
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  // Glassmorphic Weather & Notification Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4C0B58).withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        margin: const EdgeInsets.only(right: 12),
                        child: Row(
                          children: [
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: _isLoadingWeather
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4C0B58)))
                                  : const Icon(
                                      Icons.wb_cloudy_rounded,
                                      color: Color(0xFF4C0B58),
                                      size: 26,
                                    ),
                              onPressed: _showWeatherDialog,
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 1.5,
                              height: 20,
                              color: const Color(0xFF4C0B58).withOpacity(0.2),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                                color: Color(0xFF4C0B58),
                                size: 28,
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
                    ),
                  ),
                  // Search Field (Elevated glass look)
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search Here",
                          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade600),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
                content:
                    "Important Safety Alert: Always double-check your full-body harness and lanyard before every climb. Ensure the site anchor points are certified and clearly marked. Safety is our top priority when working on towers! #TowerPulse #SafetyFirst",
                likes: 124,
                likedBy: [],
              ),

              if (_showAllPosts) ...[
                // Default Static Post 2
                postCard(
                  postId: "default_safety_alert_2",
                  authorName: "Sarah Chen",
                  authorRole: "Safety Compliance",
                  content:
                      "Weather Warning: High winds expected this afternoon. Please suspend all climbing activities if wind speeds exceed 25mph. Stay safe and stay grounded! 💨🚧 #SafetyAlert #WeatherWatch",
                  likes: 85,
                  likedBy: [],
                ),
                // Default Static Post 3
                postCard(
                  postId: "default_safety_alert_3",
                  authorName: "Marcus Johnson",
                  authorRole: "Equipment Lead",
                  content:
                      "Weekly Gear Check: REMINDER to inspect your pulleys and carabiners for any signs of wear or hairline cracks. If in doubt, swap it out! Don't take chances with your gear. 🛠️👷‍♂️ #SafeGear #TowerMaintenance",
                  likes: 92,
                  likedBy: [],
                ),
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('post')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const SizedBox();
                    }

                    return Column(
                      children:
                          snapshot.data!.docs.map((doc) {
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
