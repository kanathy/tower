import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:assets_audio_player/assets_audio_player.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<String> notifications = [];
  // final assetsAudioPlayer = AssetsAudioPlayer();
  final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://towersafety-56937-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  @override
  void initState() {
    super.initState();
    _listenToEmployeeData();
  }

  void _listenToEmployeeData() {
    final employeesRef = database.ref('employees');
    employeesRef.onChildChanged.listen((event) async {
      final empId = event.snapshot.key ?? '';
      final empData = event.snapshot.value as Map?;
      if (empData == null) return;
      await _checkAndNotify(empId, empData);
    });
  }

  Future<void> _checkAndNotify(String empId, Map empData) async {
    final name = empData['name'] ?? empId;
    final towerId = empData['tower_id'] ?? 'Unknown Tower';
    final heartRate = empData['heartRate'] ?? 0;
    final oxygenLevel = empData['oxygenLevel'] ?? 0;
    final fallDetected = empData['fallDetected'] ?? false;

    final towerSnap = await database.ref('towers/$towerId/tower_name').get();
    final towerName = towerSnap.value ?? towerId;

    if (heartRate < 50) {
      _addNotification(
        "⚠ ${name}'s heart rate is critically low ($heartRate bpm) at $towerName. Take immediate action!",
      );
    }

    if (oxygenLevel < 90) {
      _addNotification(
        "⚠ ${name}'s blood oxygen level is dangerously low ($oxygenLevel%) at $towerName. Get them to safety!",
      );
    }

    if (fallDetected == true) {
      _addNotification(
        "🚨 Fall detected! ${name} has fallen from $towerName. Provide assistance immediately!",
      );
    }
  }

  void _addNotification(String message) {
    setState(() {
      notifications.insert(0, message);
    });

    /* assetsAudioPlayer.open(
      Audio('assets/sounds/alert.mp3'),
      autoStart: true,
      showNotification: false,
    ); */
  }

  /*@override
  void dispose() {
    assetsAudioPlayer.dispose();
    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body:
          notifications.isEmpty
              ? const Center(
                child: Text(
                  'No notifications yet.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.red[50],
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text(
                        notifications[index],
                        style: TextStyle(
                          color: Colors.red[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
