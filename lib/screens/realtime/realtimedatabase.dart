import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RealTimeDataPage extends StatefulWidget {
  const RealTimeDataPage({super.key});

  @override
  State<RealTimeDataPage> createState() => _RealTimeDataPageState();
}

class _RealTimeDataPageState extends State<RealTimeDataPage> {
  final databaseRef = FirebaseDatabase.instance.ref('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Real-time Data from Firebase')),
      body: StreamBuilder<DatabaseEvent>(
        stream: databaseRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final dataMap =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            final dataList = dataMap.entries.toList();

            return ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                final entry = dataList[index];
                final userData = entry.value as Map<dynamic, dynamic>;

                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(userData['name'] ?? 'No Name'),
                  subtitle: Text('Age: ${userData['age'] ?? 'Unknown'}'),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
