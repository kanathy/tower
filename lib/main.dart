import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart'; // Importing LoginScreen
import 'package:tower/initialpages/page1.dart';
import 'package:tower/initialpages/logo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tower App',
      debugShowCheckedModeBanner: false,
      home: LogoScreen(), // Set this as the starting screen
    );
  }
}
