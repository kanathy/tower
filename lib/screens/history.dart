import 'package:flutter/material.dart';
import 'package:tower/screens/chatbot.dart';
import 'package:tower/screens/profileset/profile.dart';
import 'package:tower/screens/upload.dart';
import 'package:tower/screens/home/homepage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedFilter = 'Fall Detection';
  String? selectedTower;

  final List<Map<String, String>> allData = [
    {
      'type': 'Fall Detection',
      'date': 'Wednesday, 10 April 2023',
      'heartRate': '3',
      'oxygen': '98%',
      'emergency': 'No',
      'workTime': '8 hrs',
      'tower': 'Tower A',
    },
    {
      'type': 'Fall Detection',
      'date': 'Thursday, 11 April 2023',
      'heartRate': '-',
      'oxygen': '-',
      'emergency': 'Yes',
      'workTime': '-',
      'tower': 'Tower A',
    },
    {
      'type': 'Fall Detection',
      'date': 'Thursday, 11 April 2023',
      'heartRate': '5',
      'oxygen': 'sample data',
      'emergency': 'sample data',
      'workTime': 'sample data',
      'tower': 'Tower B',
    },
    {
      'type': 'Location',
      'date': 'Friday, 12 April 2023',
      'heartRate': '-',
      'oxygen': '-',
      'emergency': '-',
      'workTime': '-',
      'tower': 'Tower C',
    },
    {
      'type': 'Location',
      'date': 'Saturday, 13 April 2023',
      'heartRate': '-',
      'oxygen': '-',
      'emergency': '-',
      'workTime': '-',
      'tower': 'Tower D',
    },
    {
      'type': 'Emergency Alerts',
      'date': 'Friday, 12 April 2023',
      'heartRate': '7',
      'oxygen': '95%',
      'emergency': 'Yes',
      'workTime': 'urgent',
      'tower': 'Tower C',
    },
  ];

  List<String> get uniqueTowers =>
      allData
          .where((d) => d['type'] == 'Location')
          .map((d) => d['tower']!)
          .toSet()
          .toList();

  List<Map<String, String>> get filteredData {
    return allData.where((d) {
      final matchType = d['type'] == selectedFilter;
      final matchTower =
          selectedFilter == 'Location'
              ? selectedTower == null || selectedTower == d['tower']
              : true;
      final matchEmergency =
          selectedFilter == 'Emergency Alerts'
              ? d['emergency']?.toLowerCase() == 'yes'
              : true;
      return matchType && matchTower && matchEmergency;
    }).toList();
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
          leading: const BackButton(color: Color(0xFF4C0B58)),
          title: const Text(
            'History',
            style: TextStyle(
              color: Color(0xFF4C0B58),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _searchBar(),
          const SizedBox(height: 16),
          _filterRow(),
          if (selectedFilter == 'Location') _towerDropdown(),
          Expanded(
            child: ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (_, i) => _historyCard(filteredData[i]),
            ),
          ),
        ],
      ),
        bottomNavigationBar: CurvedNavigationBar(
          color: const Color(0xffede7f6),
          backgroundColor: Colors.transparent,
          index: 1, // Select the initial tab index
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
      ),
    );
  }

  Widget _searchBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: const [
                SizedBox(width: 12),
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search Here',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text('See All', style: TextStyle(color: Colors.grey)),
      ],
    ),
  );

  Widget _filterRow() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children:
          [
            'Fall Detection',
            'Location',
            'Emergency Alerts',
          ].map((label) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _filterButton(label),
          )).toList(),
    ),
  );

  Widget _filterButton(String label) {
    final sel = label == selectedFilter;
    return ElevatedButton(
      onPressed:
          () => setState(() {
            selectedFilter = label;
            selectedTower = null;
          }),
      style: ElevatedButton.styleFrom(
        backgroundColor: sel ? Colors.black : Colors.grey.shade700,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _towerDropdown() => Padding(
    padding: const EdgeInsets.all(16.0),
    child: DropdownButton<String>(
      isExpanded: true,
      hint: const Text('Select Tower'),
      value: selectedTower,
      items:
          uniqueTowers
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
      onChanged: (v) => setState(() => selectedTower = v),
    ),
  );

  Widget _historyCard(Map<String, String> d) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF3EAFE),
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d['date']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Technicians Safety Monitoring',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text('Delete Record', style: TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              d['type']!,
              style: const TextStyle(
                color: Color(0xFF4C0B58),
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4C0B58),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Occured',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _infoRow('Heart Rate', d['heartRate']!),
        _infoRow('Oxygen Level', d['oxygen']!),
        _infoRow('Emergency button Pressed', d['emergency']!),
        _infoRow('Working Time', d['workTime']!),
        _infoRow('Worked Tower Site', d['tower']!),
      ],
    ),
  );

  Widget _infoRow(String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(v),
      ],
    ),
  );
}
