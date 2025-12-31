import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  double _sliderValue = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  final List<Map<String, dynamic>> _emojis = [
    {'icon': '😖', 'label': 'Worst'},
    {'icon': '😟', 'label': 'Not Good'},
    {'icon': '😐', 'label': 'Fine'},
    {'icon': '😊', 'label': 'Look Good'},
    {'icon': '😍', 'label': 'Very Good'},
  ];

  int get _selectedEmoji => _sliderValue.round();

  void _updateSlider(int index) {
    setState(() {
      _sliderValue = index.toDouble();
    });
  }

  void _updateEmoji(double value) {
    setState(() {
      _sliderValue = value;
    });
  }

  Future<void> _submitFeedback() async {
    if (_nameController.text.trim().isEmpty &&
        _commentsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name or feedback')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // Get existing feedbacks
    final String? storedData = prefs.getString('user_feedbacks');
    List<Map<String, dynamic>> feedbackList = [];
    if (storedData != null) {
      feedbackList = List<Map<String, dynamic>>.from(jsonDecode(storedData));
    }

    // Add new feedback
    final newFeedback = {
      'name': _nameController.text.trim(),
      'contact': _contactController.text.trim(),
      'email': _emailController.text.trim(),
      'feedback': _commentsController.text.trim(),
      'emoji': _emojis[_selectedEmoji]['icon'],
      'time': DateTime.now().toString(),
    };
    feedbackList.add(newFeedback);

    // Save back to SharedPreferences
    await prefs.setString('user_feedbacks', jsonEncode(feedbackList));

    // Clear all fields
    _nameController.clear();
    _contactController.clear();
    _emailController.clear();
    _commentsController.clear();
    setState(() {
      _sliderValue = 0;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Your feedback is submitted')));
  }

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
          leading: const BackButton(color: Colors.black),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'FeedBack',
            style: TextStyle(
              color: Color(0xFF4B1C7D),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(label: 'Name', controller: _nameController),
              const SizedBox(height: 15),
              _buildTextField(
                label: 'Contact Number',
                controller: _contactController,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                label: 'Email Address',
                controller: _emailController,
              ),
              const SizedBox(height: 25),
              const Text(
                'Share your experience in scaling',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B1C7D),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_emojis.length, (index) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _updateSlider(index);
                        },
                        child: Text(
                          _emojis[index]['icon'],
                          style: TextStyle(
                            fontSize: 28,
                            color:
                                _selectedEmoji == index
                                    ? Colors.orange
                                    : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _emojis[index]['label'],
                        style: const TextStyle(
                          color: Color(0xFF4B1C7D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 15),
              Slider(
                value: _sliderValue,
                onChanged: (value) {
                  _updateEmoji(value);
                },
                min: 0,
                max: (_emojis.length - 1).toDouble(),
                divisions: _emojis.length - 1,
                activeColor: const Color(0xFF4B1C7D),
                inactiveColor: const Color(0xFFE0BBE4),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _commentsController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Add your comments...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(15),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B1C7D),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _submitFeedback,
                  child: const Text(
                    'SUBMIT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4B1C7D),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF4B1C7D)),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF4B1C7D)),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
