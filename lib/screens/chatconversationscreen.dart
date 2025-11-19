import 'package:flutter/material.dart';
import 'package:tower/screens/history.dart';
import 'package:tower/screens/chatbot.dart';
import 'package:tower/screens/profileset/profile.dart';
import 'package:tower/screens/upload.dart';
import 'package:tower/screens/home/homepage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat UI',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {"text": "Hello Nice", "timestamp": "02:10 PM", "sender": "Chatbot"},
    {
      "text": "Welcome to LiveChat\nI was made with Flutter. ",
      "timestamp": "02:10 PM",
      "sender": "Chatbot",
    },
  ];

  void _sendMessage() {
    setState(() {
      _messages.add({
        "text": _controller.text,
        "timestamp": "02:20 PM", // Example timestamp
        "sender": "User",
      });
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
      body: Column(
        children: [
          // Display chat messages with sender and timestamp
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                var message = _messages[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment:
                        message["sender"] == "User"
                            ? MainAxisAlignment
                                .end // Right-align for user messages
                            : MainAxisAlignment
                                .start, // Left-align for chatbot messages
                    children: [
                      if (message["sender"] == "Chatbot")
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.purple,
                          child: Icon(
                            Icons.chat_bubble,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment:
                            message["sender"] == "User"
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                        children: [
                          Text(
                            message["sender"]!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  message["sender"] == "Chatbot"
                                      ? Colors.purple[50]
                                      : Colors.blue[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  message["sender"] == "User"
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message["text"]!,
                                  style: TextStyle(
                                    color:
                                        message["sender"] == "Chatbot"
                                            ? Colors.black
                                            : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  message["timestamp"]!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (message["sender"] == "User") SizedBox(width: 10),
                    ],
                  ),
                );
              },
            ),
          ),
          // Input field for new messages with file attachment button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Write a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.attach_file, color: Colors.grey),
                  onPressed: () {
                    // Implement file attachment logic here
                  },
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.purple),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: Color(0xffede7f6),
        backgroundColor: Colors.white,
        index: 0, // Select the initial tab index
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
        items: [
          Icon(
            Icons.home,
            size: 30,
            color: Color.fromARGB(255, 76, 11, 88), // Selected color
          ),
          Icon(
            Icons.history,
            size: 30,
            color: Color.fromARGB(255, 76, 11, 88), // Unselected color
          ),
          Icon(
            Icons.add,
            size: 30,
            color: Color.fromARGB(255, 76, 11, 88), // Unselected color
          ),
          Icon(
            Icons.chat,
            size: 30,
            color: Color.fromARGB(255, 76, 11, 88), // Unselected color
          ),
          Icon(
            Icons.person,
            size: 30,
            color: Color.fromARGB(255, 76, 11, 88), // Unselected color
          ),
        ],
        animationCurve: Curves.easeInOut, // Optional for animation effect
        animationDuration: const Duration(
          milliseconds: 300,
        ), // Optional for animation effect
      ),
    );
  }
}
