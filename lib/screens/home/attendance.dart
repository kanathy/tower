// Add these imports at the top if not already there
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tower/screens/home/homepage.dart';
import 'package:tower/screens/history.dart';
import 'package:tower/screens/chatbot.dart';
import 'package:tower/screens/profileset/profile.dart';
import 'package:tower/screens/upload.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class SafetyChecklistScreen extends StatefulWidget {
  const SafetyChecklistScreen({super.key});
  @override
  State<SafetyChecklistScreen> createState() => _SafetyChecklistScreenState();
}

class _SafetyChecklistScreenState extends State<SafetyChecklistScreen> {
  final Map<String, bool> _checkedItems = {};
  final Map<String, bool> _expandedSections = {};

  final TextEditingController _dateController = TextEditingController();
  String? _selectedSite;

  final List<String> _sites = ['Tower A', 'Tower B', 'Tower C', 'Tower D'];

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
        title: const Text(
          'Safety Checklist',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 76, 11, 88),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Full Name',
              style: TextStyle(color: Color.fromARGB(255, 76, 11, 88)),
            ),
            const SizedBox(height: 4),
            _textField('Enter Your Name'),

            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Site',
                        style: TextStyle(
                          color: Color.fromARGB(255, 76, 11, 88),
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: _selectedSite,
                        items:
                            _sites
                                .map(
                                  (site) => DropdownMenuItem(
                                    value: site,
                                    child: Text(site),
                                  ),
                                )
                                .toList(),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: 'Select Site',
                        ),
                        onChanged: (val) => setState(() => _selectedSite = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(
                          color: Color.fromARGB(255, 76, 11, 88),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Pick a Date',
                          prefixIcon: const Icon(Icons.calendar_today),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            _dateController.text = DateFormat(
                              'dd/MM/yyyy',
                            ).format(picked);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _buildChecklistSection(
              title: 'Device Check',
              color: const Color(0xFFFFF5C2),
              titleColor: Color.fromARGB(255, 76, 11, 88),
              items: [
                'Heart Rate within Safe range 78 bpm',
                'Oxygen level acceptable 98%',
              ],
            ),
            _buildChecklistSection(
              title: 'PPE',
              color: const Color(0xFFE2F3F8),
              titleColor: Color.fromARGB(
                255,
                76,
                11,
                88,
              ), // Custom title color for PPE
              items: [
                'Helmet worn properly',
                'Non-slip gloves worn',
                'Safety shoes worn',
              ],
            ),
            _buildChecklistSection(
              title: 'Environment Check',
              color: const Color(0xFFFFE3EC),
              titleColor: Color.fromARGB(255, 76, 11, 88),
              items: [
                'Communication Device is working',
                'Emergency exits clear',
                'No loose tools on platform',
              ],
            ),
            _buildChecklistSection(
              title: 'Environment Awareness',
              color: const Color(0xFFEEE5FF),
              titleColor: Color.fromARGB(255, 76, 11, 88),
              items: [
                'Weather is safe for climbing',
                'No lightning / storm warnings',
                'Wind speed within limits',
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 76, 11, 88),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 50,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Attendance marked successfully!'),
                  ),
                );
              },
              child: const Text(
                'Mark The Attendance',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
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

  Widget _textField(String hint, {Widget? prefix}) => TextField(
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: prefix,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  Widget _buildChecklistSection({
    required String title,
    required Color color,
    required List<String> items,
    Color? titleColor, // Optional title text color
  }) {
    _expandedSections.putIfAbsent(title, () => false);
    final isExpanded = _expandedSections[title]!;
    final visibleItems = isExpanded ? items : items.take(2).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: titleColor ?? Colors.black,
                ),
              ),
              GestureDetector(
                onTap:
                    () =>
                        setState(() => _expandedSections[title] = !isExpanded),
                child: Text(
                  isExpanded ? 'Show Less' : 'See All',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...visibleItems.map((e) {
            _checkedItems.putIfAbsent(e, () => false);
            final checked = _checkedItems[e]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _checkedItems[e] = !checked),
                    child: Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        color:
                            checked
                                ? const Color.fromARGB(255, 76, 11, 88)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color.fromARGB(255, 76, 11, 88),
                        ),
                      ),
                      child:
                          checked
                              ? const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              )
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(e)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
