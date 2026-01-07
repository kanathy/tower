import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackAdminPage extends StatefulWidget {
  const FeedbackAdminPage({super.key});

  @override
  State<FeedbackAdminPage> createState() => _FeedbackAdminPageState();
}

class _FeedbackAdminPageState extends State<FeedbackAdminPage> {
  List<Map<String, dynamic>> _feedbackList = [];

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString('user_feedbacks');

    if (storedData != null) {
      final List decoded = jsonDecode(storedData);
      setState(() {
        _feedbackList = List<Map<String, dynamic>>.from(decoded);
      });
    }
  }

  Future<void> _deleteFeedback(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _feedbackList.removeAt(index);
    await prefs.setString('user_feedbacks', jsonEncode(_feedbackList));
    setState(() {});
  }

  Color _getEmojiColor(String? emoji) {
    switch (emoji) {
      case '😊':
      case '😃':
        return const Color(0xFF4CAF50);
      case '😐':
        return const Color(0xFFFF9800);
      case '😞':
      case '😢':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF4C0B58);
    }
  }

  String _getRatingLabel(String? emoji) {
    switch (emoji) {
      case '😊':
      case '😃':
        return 'Positive';
      case '😐':
        return 'Neutral';
      case '😞':
      case '😢':
        return 'Needs Attention';
      default:
        return 'Feedback';
    }
  }

  void _showFeedbackDetails(Map<String, dynamic> fb, int index) {
    final color = _getEmojiColor(fb['emoji']);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    fb['emoji'] ?? '💬',
                    style: const TextStyle(fontSize: 56),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fb['name'] ?? 'Anonymous User',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getRatingLabel(fb['emoji']),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.message_rounded, size: 18, color: Colors.grey[500]),
                        const SizedBox(width: 8),
                        Text(
                          "Feedback",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fb['feedback'] ?? 'No message provided.',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2D3436),
                        height: 1.6,
                      ),
                    ),
                    if (fb['time'] != null) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 16, color: Colors.grey[400]),
                          const SizedBox(width: 6),
                          Text(
                            fb['time'].toString().substring(0, 16),
                            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close_rounded),
                            label: const Text("Close"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                              side: BorderSide(color: Colors.grey[300]!),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _deleteFeedback(index);
                            },
                            icon: const Icon(Icons.delete_outline_rounded, size: 20),
                            label: const Text("Delete"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4C0B58), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'User Feedbacks',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4C0B58),
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            if (_feedbackList.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4C0B58).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_feedbackList.length}',
                  style: const TextStyle(
                    color: Color(0xFF4C0B58),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        body: _feedbackList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.inbox_rounded, size: 48, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No Feedbacks Yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'User feedback will appear here',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                itemCount: _feedbackList.length,
                itemBuilder: (context, index) {
                  final fb = _feedbackList[index];
                  final color = _getEmojiColor(fb['emoji']);
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _showFeedbackDetails(fb, index),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    fb['emoji'] ?? '💬',
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            fb['name'] ?? 'Anonymous',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                              color: Color(0xFF2D3436),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            _getRatingLabel(fb['emoji']),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      fb['feedback'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                    if (fb['time'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Row(
                                          children: [
                                            Icon(Icons.schedule_rounded, size: 12, color: Colors.grey[400]),
                                            const SizedBox(width: 4),
                                            Text(
                                              fb['time'].toString().substring(0, 16),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
