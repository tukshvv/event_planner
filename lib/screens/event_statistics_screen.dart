import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventStatisticsScreen extends StatefulWidget {
  final String eventId;
  const EventStatisticsScreen({super.key, required this.eventId});

  @override
  State<EventStatisticsScreen> createState() => _EventStatisticsScreenState();
}

class _EventStatisticsScreenState extends State<EventStatisticsScreen> {
  final _guestController = TextEditingController();
  final _taskController = TextEditingController();

  Future<void> _updateFirestoreField(String field, List data) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .update({field: data});
  }

  Future<void> _toggleFieldStatus(
      String field, String key, int index, List data) async {
    data[index][key] = !data[index][key];
    await _updateFirestoreField(field, data);
  }

  Future<void> _deleteItem(String field, int index, List data) async {
    data.removeAt(index);
    await _updateFirestoreField(field, data);
  }

  Future<void> _addItem(String field, String key,
      TextEditingController controller, List data) async {
    if (controller.text.trim().isEmpty) return;
    data.add({key: controller.text.trim(), 'done': false});
    controller.clear();
    await _updateFirestoreField(field, data);
  }

  Future<void> _addGuest(List guests) async {
    if (_guestController.text.trim().isEmpty) return;
    guests.add({'name': _guestController.text.trim(), 'checkedIn': false});
    _guestController.clear();
    await _updateFirestoreField('guests', guests);
  }

  @override
  Widget build(BuildContext context) {
    final docStream = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guests & Tasks'),
        backgroundColor: Colors.indigo[900],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: docStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final guests = List<Map<String, dynamic>>.from(data['guests'] ?? []);
          final tasks = List<Map<String, dynamic>>.from(data['tasks'] ?? []);
          final start = data['startTime'];
          final end = data['endTime'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (start != null && end != null) ...[
                  Text(
                    'Event Time:',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${DateTime.parse(start).toLocal()} — ${DateTime.parse(end).toLocal()}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                ],
                _sectionTitle(
                    'Guests (${guests.where((g) => g['checkedIn']).length}/${guests.length})'),
                _entryField(
                    'Add guest', _guestController, () => _addGuest(guests)),
                _listSection(
                  items: guests,
                  keyLabel: 'name',
                  statusKey: 'checkedIn',
                  field: 'guests',
                ),
                const SizedBox(height: 24),
                _sectionTitle('Tasks'),
                _entryField('Add task', _taskController,
                    () => _addItem('tasks', 'title', _taskController, tasks)),
                _listSection(
                  items: tasks,
                  keyLabel: 'title',
                  statusKey: 'done',
                  field: 'tasks',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _entryField(
      String hint, TextEditingController controller, VoidCallback onAdd) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
      ],
    );
  }

  Widget _listSection({
    required List<Map<String, dynamic>> items,
    required String keyLabel,
    required String statusKey,
    required String field,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = items[index];
        final label = item[keyLabel];
        final isChecked = item[statusKey];

        return Card(
          child: ListTile(
            leading: Checkbox(
              value: isChecked,
              onChanged: (_) =>
                  _toggleFieldStatus(field, statusKey, index, items),
            ),
            title: Text(
              label,
              style: TextStyle(
                decoration: isChecked ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteItem(field, index, items),
            ),
          ),
        );
      },
    );
  }
}
