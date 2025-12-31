import 'package:flutter/material.dart';

class AssignTaskDialog extends StatefulWidget {
  const AssignTaskDialog({super.key});

  @override
  State<AssignTaskDialog> createState() => _AssignTaskDialogState();
}

class _AssignTaskDialogState extends State<AssignTaskDialog> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign New Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Task Title'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedDate == null
                      ? 'No date chosen'
                      : 'Due: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                ),
              ),
              TextButton(
                onPressed: _pickDate,
                child: const Text('Pick Date'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty && _selectedDate != null) {
              Navigator.of(context).pop({
                'title': _titleController.text,
                'due': _selectedDate!.toIso8601String(),
              });
            }
          },
          child: const Text('Assign'),
        ),
      ],
    );
  }
}
