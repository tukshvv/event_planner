import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventCreateScreen extends StatefulWidget {
  const EventCreateScreen({super.key});

  @override
  State<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends State<EventCreateScreen> {
  final _titleController = TextEditingController();
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  final List<Map<String, dynamic>> _tasks = [];
  final List<Map<String, dynamic>> _guests = [];

  final _taskController = TextEditingController();
  final _guestController = TextEditingController();

  Future<void> addEventToFirestore() async {
    await FirebaseFirestore.instance.collection('events').add({
      'title': _titleController.text.trim(),
      'startTime': _startDateTime?.toIso8601String(),
      'endTime': _endDateTime?.toIso8601String(),
      'tasks': _tasks,
      'guests': _guests,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void _handleCreate() async {
    if (_titleController.text.isEmpty ||
        _startDateTime == null ||
        _endDateTime == null) return;

    try {
      await addEventToFirestore();
      Navigator.pushReplacementNamed(context, '/events');
    } catch (e) {
      print('Error creating event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create event')),
      );
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final selected = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStart) {
            _startDateTime = selected;
          } else {
            _endDateTime = selected;
          }
        });
      }
    }
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add({'title': _taskController.text.trim(), 'done': false});
        _taskController.clear();
      });
    }
  }

  void _addGuest() {
    if (_guestController.text.isNotEmpty) {
      setState(() {
        _guests.add({'name': _guestController.text.trim(), 'checkedIn': false});
        _guestController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200, width: 2),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'CREATE NEW EVENT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField('Event Title', _titleController),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _pickDateTime(isStart: true),
                  child: Text(_startDateTime == null
                      ? 'Pick Start Date & Time'
                      : 'Start: $_startDateTime'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _pickDateTime(isStart: false),
                  child: Text(_endDateTime == null
                      ? 'Pick End Date & Time'
                      : 'End: $_endDateTime'),
                ),
                const SizedBox(height: 16),
                _buildTextField('Add Task', _taskController, onAdd: _addTask),
                Wrap(
                  children: _tasks
                      .map((task) => Chip(label: Text(task['title'])))
                      .toList(),
                ),
                const SizedBox(height: 16),
                _buildTextField('Add Guest', _guestController,
                    onAdd: _addGuest),
                Wrap(
                  children: _guests
                      .map((guest) => Chip(label: Text(guest['name'])))
                      .toList(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _handleCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Create Event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {VoidCallback? onAdd}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: onAdd != null
            ? IconButton(icon: const Icon(Icons.add), onPressed: onAdd)
            : null,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
