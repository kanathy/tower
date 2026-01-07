import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HeartRatePage extends StatefulWidget {
  @override
  _HeartRatePageState createState() => _HeartRatePageState();
}

class _HeartRatePageState extends State<HeartRatePage> {
  int heartRate = 0; // Store the heart rate value
  int progress = 0; // The percentage for the circular progress bar
  bool isMeasuring = false; // Flag to indicate measuring state
  DatabaseReference? _ref; // Firebase reference for heart rate

  // Function to fetch heart rate from Firebase after measuring
  void startMeasuring() async {
    setState(() {
      isMeasuring = true;
      progress = 0;
    });

    // Simulate measuring progress
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(Duration(milliseconds: 50));
      setState(() {
        progress = i;
      });
    }

    // Fetch heart rate value from Firebase
    if (_ref != null) {
      final event = await _ref!.once();
      final data = event.snapshot.value;
      print('Fetched heart rate from Firebase: $data');
      int fetchedRate = 0;
      if (data is int) {
        fetchedRate = data;
      }
      setState(() {
        heartRate = fetchedRate;
        isMeasuring = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://towersafety-56937-default-rtdb.asia-southeast1.firebasedatabase.app',
    );
    _ref = database.ref('Device/BPM');
    /*// Listen for real-time changes
  _ref!.onValue.listen((event) {
    final data = event.snapshot.value;
    int fetchedRate = 0;
    if (data is int) {
      fetchedRate = data;
    }
    setState(() {
      heartRate = fetchedRate;
    });
  });*/ /////////////////this code has to be used when fetching from sensor.

    startMeasuring(); // Start measuring when the page loads
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Heart Rate',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 76, 11, 88),
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color.fromARGB(255, 76, 11, 88),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular progress bar with heart image in the center
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 330,
                  height: 330,
                  child: CircularProgressIndicator(
                    value: progress / 100,
                    strokeWidth: 12,
                    valueColor: AlwaysStoppedAnimation(
                      const Color.fromARGB(255, 220, 20, 60), // Heart color
                    ),
                  ),
                ),
                Image.asset(
                  'lib/assets/images/heart.png', // Path to your heart image
                  width: 280,
                  height: 280,
                  fit: BoxFit.cover,
                ),
                if (!isMeasuring)
                  Text(
                    '$heartRate bpm',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              isMeasuring ? 'Measuring... ($progress%)' : 'Heart Rate Updated',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            if (isMeasuring)
              Column(
                children: [
                  Text(
                    'Measuring your heart rate.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  Text(
                    'Please hold on.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
            if (!isMeasuring)
              ElevatedButton(
                onPressed: startMeasuring,
                child: Text('Measure Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 76, 11, 88),
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}
