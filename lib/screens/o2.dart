import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class BloodOxygenPage extends StatefulWidget {
  @override
  _BloodOxygenPageState createState() => _BloodOxygenPageState();
}

class _BloodOxygenPageState extends State<BloodOxygenPage> {
  int bloodOxygen = 0; // Store the blood oxygen level
  int progress = 0; // The percentage for the circular progress bar
  bool isMeasuring = false;
  DatabaseReference? _ref;

  // Function to fetch blood oxygen level from Firebase after measuring
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

    // Fetch blood oxygen value from Firebase
    if (_ref != null) {
      final event = await _ref!.once();
      final data = event.snapshot.value;
      print('Fetched data from Firebase: $data'); // <-- Add this line
      int fetchedO2 = 0;
      if (data is int) {
        fetchedO2 = data;
      }
      setState(() {
        bloodOxygen = fetchedO2;
        isMeasuring = false;
      });
    } /*else {
      setState(() {
        bloodOxygen = 0;
        isMeasuring = false;
      });
    }*/
  }

  @override
  void initState() {
    super.initState();
    // _ref = FirebaseDatabase.instance.ref('DisplayBloodOxygen');
    final database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://towersafety-56937-default-rtdb.asia-southeast1.firebasedatabase.app',
    );
    _ref = database.ref('Device/SpO2');
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
            'Blood Oxygen Level',
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
            // Circular progress bar with blood drop image in the center
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
                      const Color.fromARGB(255, 18, 81, 116),
                    ),
                  ),
                ),

                Image.asset(
                  'lib/assets/images/o2.png', // Path to your blood drop image
                  width: 280,
                  height: 280,
                  fit: BoxFit.cover,
                ),

                if (!isMeasuring)
                  Padding(
                    padding: const EdgeInsets.only(left: 80),
                    child: Text(
                      '$bloodOxygen%',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 30),
            Text(
              isMeasuring
                  ? 'Measuring... ($progress%)'
                  : 'Blood Oxygen Updated',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),

            if (isMeasuring)
              Column(
                children: [
                  Text(
                    'Measuring your blood oxygen.',
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
