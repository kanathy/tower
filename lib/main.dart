import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart'; // Importing LoginScreen
import 'package:tower/initialpages/page1.dart';
import 'package:tower/initialpages/logo.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tower/theme/theme_notifier.dart';
import 'package:tower/adminscreens/adminpanel/staffs_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeNotifier(),
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Tower App',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            primaryColor: const Color(0xFF5A189A),
            scaffoldBackgroundColor: Colors.white,
            brightness: Brightness.light,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF4C0B58)),
              titleTextStyle: TextStyle(
                color: Color(0xFF4C0B58),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          darkTheme: ThemeData(
            primaryColor: const Color(0xFF5A189A),
            scaffoldBackgroundColor: const Color(0xFF121212),
            brightness: Brightness.dark,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F1F1F),
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            colorScheme: const ColorScheme.dark(
               primary: Color(0xFF9D4EDD),
               secondary: Color(0xFFC77DFF),
            ),
          ),
          routes: {
            '/staffs': (context) => const StaffsScreen(),
          },
          home: LogoScreen(),
        );
      },
    );
  }
}
