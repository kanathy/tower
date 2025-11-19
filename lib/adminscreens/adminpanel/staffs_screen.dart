import 'package:tower/adminscreens/adminpanel/employee/employee_details_screen.dart';
import 'package:tower/adminscreens/adminpanel/report_analytics_screen.dart';
import 'package:tower/adminscreens/adminpanel/safety_measures_screen.dart';
import 'package:tower/adminscreens/adminpanel/attendance_screen.dart';
import 'package:tower/adminscreens/adminpanel/calendar_screen.dart';
import 'package:tower/adminscreens/adminpanel/feedback_screen.dart';
import 'package:tower/adminscreens/adminpanel/notification.dart';
import 'package:tower/adminscreens/adminpanel/staffs_screen.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class employee {
  String emp_id;
  String name;
  // String photoUrl;
  String dob;
  String email;
  String address;
  String join_date;

  employee({
    required this.emp_id,
    required this.name,
    // required this.photoUrl,
    required this.dob,
    required this.email,
    required this.address,
    required this.join_date,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      //  'photoUrl': photoUrl,
      'dob': dob,
      'email': email,
      'address': address,
      'join_date': join_date,
    };
  }

  factory employee.fromMap(String id, Map<String, dynamic> map) {
    return employee(
      emp_id: id,
      name: map['name'] ?? '',
      //  photoUrl: map['photoUrl'] ?? '',
      dob: map['dob'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      join_date: map['join_date'] ?? '',
    );
  }
}

class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  List<employee> _allemployees = [];
  List<employee> _filteredemployees = [];

  @override
  void initState() {
    super.initState();
    _loademployees();
    _searchController.addListener(_filteremployees);
  }

  Future<void> _loademployees() async {
    final snapshot = await _firestore.collection('employees').get();
    final employees =
        snapshot.docs
            .map((doc) => employee.fromMap(doc.id, doc.data()))
            .toList();

    setState(() {
      _allemployees = employees;
      _filteredemployees = employees;
    });
  }

  void _filteremployees() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredemployees =
          _allemployees
              .where((e) => e.name.toLowerCase().contains(query))
              .toList();
    });
  }

  Future<void> _addemployee(employee employee) async {
    final docRef = await _firestore
        .collection('employees')
        .add(employee.toMap());
    setState(() {
      _allemployees.add(employee);
      _filteredemployees = _allemployees;
    });
  }

  Future<void> _deleteemployee(employee employee) async {
    await _firestore.collection('employees').doc(employee.emp_id).delete();
    _loademployees();
  }

  void _showAddemployeeDialog() {
    final nameController = TextEditingController();
    final photoController = TextEditingController();
    final dobController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    final joinController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Add New employee'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField('Name', nameController),
                  _buildTextField('Photo URL', photoController),
                  _buildTextField('DOB (YYYY-MM-DD)', dobController),
                  _buildTextField('Email', emailController),
                  _buildTextField('Address', addressController),
                  _buildTextField('Join Date (YYYY-MM-DD)', joinController),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newemployee = employee(
                    emp_id: '',
                    name: nameController.text.trim(),
                    //photoUrl: photoController.text.trim(),
                    dob: dobController.text.trim(),
                    email: emailController.text.trim(),
                    address: addressController.text.trim(),
                    join_date: joinController.text.trim(),
                  );
                  await _addemployee(newemployee);
                  Navigator.pop(ctx);
                  _loademployees();
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  void _showemployeeDetails(employee employee) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(employee.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 50,
                  // backgroundImage: NetworkImage(employee.photoUrl),
                ),
                const SizedBox(height: 10),
                _buildDetailRow('DOB', employee.dob),
                _buildDetailRow('Email', employee.email),
                _buildDetailRow('Address', employee.address),
                _buildDetailRow('Join Date', employee.join_date),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _deleteemployee(employee);
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Color(0xFF4C0B58)),
        title: const Text(
          'Staff Details',
          style: TextStyle(
            color: Color(0xFF4C0B58),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search staff by name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _filteredemployees.isEmpty
                    ? const Center(child: Text('No staff found'))
                    : ListView.separated(
                      itemCount: _filteredemployees.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final employee = _filteredemployees[index];
                        return ListTile(
                          leading: CircleAvatar(
                            // backgroundImage: NetworkImage(employee.photoUrl),
                            radius: 25,
                          ),
                          title: Text(employee.name),
                          subtitle: Text('Email: ${employee.email}'),
                          onTap: () => _showemployeeDetails(employee),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4C0B58),
        child: const Icon(Icons.add),
        onPressed: _showAddemployeeDialog,
        tooltip: 'Add New Staff',
      ),
    );
  }
}
