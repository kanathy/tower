// File: screens/adminpanel/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:tower/adminscreens/adminpanel/reminder.dart';
import 'package:tower/adminscreens/widgets/dashboard_card.dart'; // Adjust import based on your actual structure
import 'package:tower/adminscreens/widgets/category_item.dart'; // Adjust import based on your actual structure
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tower/adminscreens/adminpanel/employee/employee_details_screen.dart';
import 'package:tower/adminscreens/adminpanel/report_analytics_screen.dart';
import 'package:tower/adminscreens/adminpanel/safety_measures_screen.dart';
import 'package:tower/adminscreens/adminpanel/attendance_screen.dart';
import 'package:tower/adminscreens/adminpanel/calendar_screen.dart';
import 'package:tower/adminscreens/adminpanel/feedback_screen.dart';
import 'package:tower/adminscreens/adminpanel/notification.dart';
import 'package:tower/adminscreens/adminpanel/staffs_screen.dart';
import 'package:tower/adminscreens/adminpanel/tower/tower_details.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  File? _profileImage;
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background color from Figma
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 100, // make room for Hi Admin + Welcome text
        leadingWidth: 85,
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 42.5,
                backgroundImage:
                    _profileImage != null
                        ? FileImage(_profileImage!)
                        : const AssetImage('lib/assets/images/avatar.png')
                            as ImageProvider,
                backgroundColor: Colors.grey[300],
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Hi Admin!',
              style: TextStyle(
                color: Color.fromARGB(255, 73, 27, 109),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Welcome to TowerPulse!',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4.0),

            _buildSearchBar(),
            const SizedBox(height: 24.0),

            _buildMainCardsGrid(context), // Pass context for navigation
            const SizedBox(height: 2.0),

            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 73, 27, 109),
              ),
            ),
            const SizedBox(height: 12.0),
            _buildCategoriesRow(context), // Pass context for navigation
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search Here',
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: const Icon(Icons.mic, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
        ),
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  Widget _buildMainCardsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: 0.9,
      children: [
        DashboardCard(
          title: 'Employee Details',
          iconPath:
              'lib/assets/images/attendance.png', // Replace with your actual asset path
          backgroundColor: const Color.fromARGB(230, 230, 230, 255),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmployeeDetailsScreen()),
            );
          },
        ),
        DashboardCard(
          title: 'Tower Details',
          iconPath:
              'lib/assets/images/tower.png', // Replace with your actual asset path
          backgroundColor: const Color.fromARGB(230, 230, 230, 255),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TowerDetailsScreen()),
            );
          },
        ),
        DashboardCard(
          title: 'Report Analytics',
          iconPath:
              'lib/assets/images/analytics_icon.png', // Replace with your actual asset path
          backgroundColor: const Color.fromARGB(230, 230, 230, 255),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportAnalyticsScreen()),
            );
          },
        ),
        DashboardCard(
          title: 'Safety Measures',
          iconPath:
              'lib/assets/images/safety_icon.png', // Replace with your actual asset path
          backgroundColor: const Color.fromARGB(230, 230, 230, 255),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SafetyMeasuresScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoriesRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CategoryItem(
            title: 'Reminders',
            iconPath: 'lib/assets/images/reminder.png',
            backgroundColor: const Color(0xFFF0F0F0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReminderScreen()),
              );
            },
          ),
          const SizedBox(width: 12.0),
          CategoryItem(
            title: 'Calendar',
            iconPath: 'lib/assets/images/calender.png',
            backgroundColor: const Color(0xFFF0F0F0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              );
            },
          ),
          const SizedBox(width: 12.0),
          CategoryItem(
            title: 'Staffs',
            iconPath: 'lib/assets/images/staffs.png',
            backgroundColor: const Color(0xFFF0F0F0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StaffPage()),
              );
            },
          ),
          const SizedBox(width: 12.0),
          CategoryItem(
            title: 'Feedback',
            iconPath: 'lib/assets/images/feedback.png',
            backgroundColor: const Color(0xFFF0F0F0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedbackAdminPage()),
              );
            },
          ),
          const SizedBox(width: 12.0),
          // Add more categories as needed
        ],
      ),
    );
  }
}
