import 'package:flutter/material.dart';
import 'package:tower/screens/chatconversationscreen.dart';
import 'package:tower/screens/history.dart';
import 'package:tower/screens/profileset/profile.dart';
import 'package:tower/screens/upload.dart';
import 'package:tower/screens/home/homepage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  runApp(ChatBotApp());
}

class ChatBotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatBotScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatBotScreen extends StatelessWidget {
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4C0B58)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: const Text(
            "Chat Bot",
            style: TextStyle(
              color: Color(0xFF4C0B58),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Text("Chat with us!", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 50),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      top: 50,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Hello! Nice to see you here! By pressing the "Start chat" button you agree to have your personal data processed as described in our Privacy Policy',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ChatScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple[100],
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          child: const Text(
                            "Start chat",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    top: -30,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFF4C0B58),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: CurvedNavigationBar(
          color: const Color(0xffede7f6),
          backgroundColor: Colors.transparent,
          index: 3, // Chat Tab Index
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
