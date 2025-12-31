import 'package:flutter/material.dart';
import 'package:tower/screens/home/homepage.dart';
import 'package:tower/screens/history.dart';
import 'package:tower/screens/chatbot.dart';
import 'package:tower/screens/profileset/profile.dart';
import 'package:tower/screens/upload.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class TaskToDoScreen extends StatefulWidget {
  const TaskToDoScreen({super.key});
  @override
  State<TaskToDoScreen> createState() => _TaskToDoScreenState();
}

class _TaskToDoScreenState extends State<TaskToDoScreen> {
  bool _showAll = false;
  String _selectedCategory = 'All';

  final List<_TaskItem> _tasks = [
    _TaskItem(
      'Check Tower Power Supply',
      'Today',
      const Color(0xFFe4f9f5),
      'Daily',
    ),
    _TaskItem(
      'Inspect Generator Fuel Level',
      'Today',
      const Color(0xFFf3e5f5),
      'Daily',
    ),
    _TaskItem(
      'Antenna Alignment Check',
      'Yesterday',
      const Color(0xFFfff3e0),
      'Weekly',
    ),
    _TaskItem(
      'Signal Strength Measurement',
      '3 Days ago',
      const Color(0xFFfce4ec),
      'Weekly',
    ),
    _TaskItem(
      'Battery Backup Maintenance',
      'Last Monday',
      const Color(0xFFe8f5e9),
      'Monthly',
    ),
    _TaskItem(
      'Tower Safety Inspection',
      '1 Week ago',
      const Color(0xFFede7f6),
      'Monthly',
    ),
    _TaskItem(
      'Update Maintenance Report',
      'Last Month',
      const Color(0xFFfbe9e7),
      'Monthly',
    ),
  ];

  List<_TaskItem> get _filteredTasks {
    final visible =
        _selectedCategory == 'All'
            ? _tasks
            : _tasks.where((t) => t.type == _selectedCategory).toList();
    return _showAll ? visible : visible.take(5).toList();
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
        bottomNavigationBar: CurvedNavigationBar(
          color: Color(0xffede7f6),
          backgroundColor: Colors.transparent,
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Task To Do',
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
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                ),
          ),
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildCalendar(),
            const SizedBox(height: 20),
            _buildProgressSection(),
            const SizedBox(height: 20),
            _buildTasksSection(),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Oct, 2020',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 76, 11, 88),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            return Column(
              children: [
                Text(['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'][i]),
                const SizedBox(height: 8),
                i == 1
                    ? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '4',
                        style: TextStyle(
                          color: Color.fromARGB(255, 76, 11, 88),
                        ),
                      ),
                    )
                    : Text('${i + 3}'),
              ],
            );
          })..add(const Icon(Icons.calendar_today, color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Progress'),
        const SizedBox(height: 10),
        Row(
          children: [
            _progressCard(
              'Daily Task',
              const Color.fromARGB(255, 245, 211, 223),
              'Daily',
            ),
            const SizedBox(width: 10),
            _progressCard(
              'Weekly Task',
              const Color.fromARGB(255, 255, 252, 225),
              'Weekly',
            ),
            const SizedBox(width: 10),
            _progressCard(
              'Monthly Task',
              const Color.fromARGB(255, 219, 239, 255),
              'Monthly',
            ),
          ],
        ),
      ],
    );
  }

  Widget _progressCard(String title, Color color, String type) {
    final bool isSelected = _selectedCategory == type;

    return Expanded(
      child: GestureDetector(
        onTap:
            () => setState(() {
              _selectedCategory = type;
              _showAll = false;
            }),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? color.withOpacity(0.8) // darker when selected
                    : color.withOpacity(1), // original when not selected
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                type == 'Daily'
                    ? Icons.calendar_today
                    : type == 'Weekly'
                    ? Icons.view_week
                    : Icons.calendar_month,
                color: const Color.fromARGB(255, 76, 11, 88),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tasks',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color.fromARGB(255, 76, 11, 88),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _showAll = !_showAll),
              child: Text(
                _showAll ? 'Show Less' : 'See All',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_filteredTasks.isEmpty)
          const Text("No tasks found for this category."),
        for (final task in _filteredTasks)
          _taskCard(task.title, task.subtitle, task.bgColor),
      ],
    );
  }

  Widget _taskCard(String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7E30E1), Color(0xFF49108B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 76, 11, 88),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color.fromARGB(255, 76, 11, 88),
        ),
      ),
    ],
  );
}

class _TaskItem {
  final String title;
  final String subtitle;
  final Color bgColor;
  final String type; // Daily, Weekly, Monthly
  const _TaskItem(this.title, this.subtitle, this.bgColor, this.type);
}
