import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:assets_audio_player/assets_audio_player.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:just_audio/just_audio.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<String> notifications = [];
  late AudioPlayer audioPlayer;

  final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://towersafety-56937-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    _loadHistoricalNotifications();
    _listenToDeviceData();
  }

  // Load old notifications from Firebase
  void _loadHistoricalNotifications() async {
    final notificationsRef = database.ref('notifications');
    final snapshot = await notificationsRef.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map?;
      if (data != null) {
        final loadedNotifications = <String>[];
        data.forEach((key, value) {
          if (value is Map && value['message'] != null) {
            loadedNotifications.add(value['message'].toString());
          }
        });

        setState(() {
          notifications.addAll(loadedNotifications.reversed);
        });
      }
    }
  }

  // Listen to device data changes
  void _listenToDeviceData() {
    final deviceRef = database.ref('Device');

    deviceRef.onValue.listen((event) async {
      final deviceData = event.snapshot.value as Map?;
      if (deviceData == null) return;

      await _checkAndNotifyFromDevice(deviceData);
    });
  }

  // Logic to check vitals & notify
  Future<void> _checkAndNotifyFromDevice(Map deviceData) async {
    final name = deviceData['Emp_name'] ?? 'Unknown';
    final towerId = deviceData['TowerID'] ?? 'Unknown Tower';

    final bpmRaw = deviceData['BPM'] ?? deviceData['Avg BPM'];
    final spO2Raw =
        deviceData['SpO2'] ?? deviceData['oxygenLevel'] ?? deviceData['Oxygen'];
    final fallRaw = deviceData['FallDetected'] ?? deviceData['fallDetected'];

    final heartRate = _parseToInt(bpmRaw);
    final oxygenLevel = _parseToInt(spO2Raw);
    final fallDetected = _parseToBool(fallRaw);

    String towerName = towerId;

    try {
      final towerSnap = await database.ref('towers/$towerId/tower_name').get();
      if (towerSnap.exists && towerSnap.value != null) {
        towerName = towerSnap.value.toString();
      }
    } catch (_) {}

    if (heartRate > 0 && heartRate < 50) {
      _addNotification(
        "⚠ ${name}'s heart rate is critically low ($heartRate bpm) at $towerName. Take immediate action!",
      );
    }

    if (oxygenLevel > 0 && oxygenLevel < 90) {
      _addNotification(
        "⚠ ${name}'s oxygen level is dangerously low ($oxygenLevel%) at $towerName!",
      );
    }

    if (fallDetected == true) {
      _addNotification(
        "🚨 Fall detected! ${name} has fallen at $towerName. Provide assistance immediately!",
      );
    }
  }

  // Convert dynamic values safely
  int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  bool _parseToBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;

    final s = value.toString().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }

  // Add new notification
  void _addNotification(String message) {
    setState(() {
      notifications.insert(0, message);
    });

    final ref = database.ref('notifications');
    ref.push().set({
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });

    _showEmergencyPopup(message);
    _playAlertSound();
  }

  // Play alarm sound
  Future<void> _playAlertSound() async {
    try {
      await audioPlayer.setAsset('assets/sounds/alert.mp3');
      await audioPlayer.play();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  // Emergency popup
  void _showEmergencyPopup(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.red[50],
          icon: const Icon(Icons.warning, color: Colors.red, size: 40),
          title: const Text(
            'EMERGENCY ALERT',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  // UI
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
        appBar: AppBar(
          title: const Text(
            'Admin Notifications',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
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
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
