import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tower/adminscreens/widgets/assign_task_dialog.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final String employeeId;

  const EmployeeDetailScreen({super.key, required this.employeeId});

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
      child: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('employees')
                .doc(employeeId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
              body: const Center(child: Text('Employee not found')),
            );
          }

          final employeeData = snapshot.data!.data() as Map<String, dynamic>;
          final List tasks = employeeData['tasks'] ?? [];

          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text('Employee Details'),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(
                color: Color.fromARGB(255, 73, 27, 109),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  onPressed: () => _deleteEmployee(context),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Avatar + Name
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              employeeData['avatarUrl'] != null &&
                                      employeeData['avatarUrl']
                                          .toString()
                                          .isNotEmpty
                                  ? NetworkImage(employeeData['avatarUrl'])
                                  : const AssetImage(
                                        'lib/assets/images/user_placeholder.png',
                                      )
                                      as ImageProvider,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          employeeData['name'] ?? 'Unnamed',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 73, 27, 109),
                          ),
                        ),
                        Text(
                          employeeData['designation'] ?? 'Staff',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Personal Info
                  _sectionTitle('Personal Information'),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _infoRow(
                            Icons.location_on,
                            'Address',
                            employeeData['address'] ?? 'N/A',
                          ),
                          const Divider(),
                          _infoRow(
                            Icons.phone,
                            'Phone',
                            employeeData['phone'] ?? 'N/A',
                          ),
                          const Divider(),
                          _infoRow(
                            Icons.calendar_month,
                            'Join Date',
                            employeeData['joiningDate'] ?? 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Tasks
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle('Assigned Tasks'),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Color.fromARGB(255, 73, 27, 109),
                        ),
                        onPressed: () => _assignTask(context),
                      ),
                    ],
                  ),

                  tasks.isEmpty
                      ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('No tasks assigned'),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index] as Map<String, dynamic>;
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.task),
                              title: Text(task['title'] ?? ''),
                              subtitle: Text('Due: ${task['due'] ?? ''}'),
                            ),
                          );
                        },
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 73, 27, 109),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _assignTask(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const AssignTaskDialog(),
    );

    if (result != null) {
      await FirebaseFirestore.instance
          .collection('employees')
          .doc(employeeId)
          .update({
            'tasks': FieldValue.arrayUnion([result]),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Task Assigned')));
    }
  }
  Future<void> _deleteEmployee(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Staff?'),
        content: const Text('Are you sure you want to remove this staff member permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('employees')
          .doc(employeeId)
          .delete();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff member deleted')),
        );
      }
    }
  }
}
