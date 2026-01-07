import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

/// ⚠️ API Key is now loaded from .env
/// If looking for the key, check the .env file in the root directory
// const String GEMINI_API_KEY = "YOUR_GEMINI_API_KEY_HERE";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gemini Chatbot',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, String>> _messages = [
    {
      "text":
          "Hi 👋 I am TowerPulse AI.\nAsk me anything about tower maintenance.",
      "sender": "Chatbot",
      "time": "Now",
    },
  ];

  /// Utility to format time safely without context
  String formattedTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final ampm = now.hour >= 12 ? "PM" : "AM";
    return "${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $ampm";
  }

  /// 🔹 SEND MESSAGE + GEMINI REPLY
  void _sendMessage() async {
    final userText = _controller.text.trim();
    if (userText.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _messages.add({
        "text": userText,
        "sender": "User",
        "time": formattedTime(),
      });
      _controller.clear();

      // typing indicator
      _messages.add({"text": "Typing...", "sender": "Chatbot", "time": ""});
    });

    final reply = await getGeminiReply(userText);

    if (!mounted) return;
    setState(() {
      _messages.removeLast(); // remove typing
      _messages.add({
        "text": reply,
        "sender": "Chatbot",
        "time": formattedTime(),
      });
    });
  }

  /// 🔹 GEMINI API CALL
  Future<String> getGeminiReply(String userMessage) async {
    // Trim the key to remove any accidental whitespace or newlines from .env
    final apiKey = dotenv.env['GEMINI_API_KEY']?.trim();
    if (apiKey == null || apiKey.isEmpty || apiKey == "YOUR_GEMINI_API_KEY_HERE") {
      print("❌ Error: API Key is missing or invalid.");
      return "Error: API Key not found. Please add your GEMINI_API_KEY to the .env file.";
    }

    print("🔑 Using API Key: ${apiKey.substring(0, 10)}...");

    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey",
    );

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": userMessage},
          ],
        },
      ],
      "generationConfig": {"temperature": 0.7, "maxOutputTokens": 200},
    });

    try {
      print("🚀 Sending request to Gemini...");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print("📩 Response Status: ${response.statusCode}");
      print("📄 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            "No response";
      } else {
        print("❌ Error ${response.statusCode}: ${response.body}");
        return "Sorry, AI service error (${response.statusCode}).";
      }
    } catch (e) {
      print("❌ Exception: $e");
      return "Sorry, AI service not available.";
    }
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

      /// 🔹 APP BAR
        appBar: AppBar(
          title: const Text(
            "TowerPulse AI",
            style: TextStyle(color: Color(0xFF4C0B58)),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF4C0B58)),
        ),

      /// 🔹 CHAT BODY
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["sender"] == "User";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.purple[200] : Colors.purple[50],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg["text"]!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg["time"] ?? "",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// 🔹 INPUT BAR
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask something...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      /// 🔹 BOTTOM NAVIGATION
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: const Color(0xffede7f6),
        items: const [
          Icon(Icons.home, color: Color(0xFF4C0B58)),
          Icon(Icons.history, color: Color(0xFF4C0B58)),
          Icon(Icons.add, color: Color(0xFF4C0B58)),
          Icon(Icons.chat, color: Color(0xFF4C0B58)),
          Icon(Icons.person, color: Color(0xFF4C0B58)),
        ],
      ),
      ),
    );
  }
}
