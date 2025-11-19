import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  const EmployeeDetailsScreen({super.key});

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Delete employee
  Future<void> _deleteEmployee(String docId) async {
    await _firestore.collection('employees').doc(docId).delete();
  }

  // Assign tower to employee
  Future<void> _assignTower(String docId, String towerName) async {
    await _firestore.collection('employees').doc(docId).update({
      'currentTower': towerName,
    });
  }

  // View employee details
  void _showEmployeeDetails(Map<String, dynamic> employee, String docId) async {
    final towerSnapshot = await _firestore.collection('towers').get();
    final towers =
        towerSnapshot.docs.map((doc) => doc['towerName'] as String).toList();

    String selectedTower = employee['currentTower'] ?? 'Unassigned';

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, setStateDialog) {
              return AlertDialog(
                title: Text(employee['name'] ?? 'No Name'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          employee['photoUrl'] ?? '',
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildDetailRow('Email', employee['email'] ?? 'N/A'),
                      _buildDetailRow('Address', employee['address'] ?? 'N/A'),
                      _buildDetailRow(
                        'Join Date',
                        employee['joinDate'] ?? 'N/A',
                      ),
                      const Divider(height: 20),
                      const Text(
                        'Assign Tower',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      DropdownButton<String>(
                        value: selectedTower.isEmpty ? null : selectedTower,
                        hint: const Text('Select Tower'),
                        items: [
                          const DropdownMenuItem(
                            value: 'Unassigned',
                            child: Text('Unassigned'),
                          ),
                          ...towers.map((tower) {
                            return DropdownMenuItem<String>(
                              value: tower,
                              child: Text(tower),
                            );
                          }),
                        ],
                        onChanged: (newTower) {
                          setStateDialog(() {
                            selectedTower = newTower!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  // Assign Tower Button
                  ElevatedButton.icon(
                    icon: const Icon(Icons.business),
                    label: const Text('Assign Tower'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      await _assignTower(docId, selectedTower);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tower "$selectedTower" assigned to ${employee['name']}',
                          ),
                        ),
                      );
                    },
                  ),

                  // Delete Button
                  TextButton(
                    onPressed: () async {
                      await _deleteEmployee(docId);
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                  // Close
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ],
              );
            },
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

  // Add new employee
  void _showAddEmployeeDialog() {
    final nameController = TextEditingController();
    final photoController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    final joinController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Add New Employee'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField('Name', nameController),
                  _buildTextField('Photo URL', photoController),
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
                  await _firestore.collection('employees').add({
                    'name': nameController.text.trim(),
                    'photoUrl': photoController.text.trim(),
                    'email': emailController.text.trim(),
                    'address': addressController.text.trim(),
                    'joinDate': joinController.text.trim(),
                    'currentTower': 'Unassigned',
                  });
                  Navigator.pop(ctx);
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

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Employee Details',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('employees').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading employees.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final employees = snapshot.data!.docs;

          if (employees.isEmpty) {
            return const Center(child: Text('No employees found.'));
          }

          return ListView.separated(
            itemCount: employees.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final doc = employees[index];
              final data = doc.data() as Map<String, dynamic>;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(data['photoUrl'] ?? ''),
                  radius: 25,
                ),
                title: Text(data['name'] ?? 'No Name'),
                subtitle: Text(
                  'Current Tower: ${data['currentTower'] ?? 'Unassigned'}',
                ),
                onTap: () => _showEmployeeDetails(data, doc.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4C0B58),
        child: const Icon(Icons.add),
        onPressed: _showAddEmployeeDialog,
        tooltip: 'Add New Employee',
      ),
    );
  }
}
