import 'package:flutter/material.dart';

class EntryConfigScreen extends StatefulWidget {
  const EntryConfigScreen({super.key});

  @override
  State<EntryConfigScreen> createState() => _EntryConfigScreenState();
}

class _EntryConfigScreenState extends State<EntryConfigScreen> {
  final TextEditingController _keeperController = TextEditingController();
  final List<String> _keepers = [
    'keeper1@email.com',
    'keeper2@email.com',
  ];

  void _addKeeper() {
    if (_keeperController.text.isNotEmpty) {
      setState(() {
        _keepers.add(_keeperController.text.trim());
        _keeperController.clear();
      });
    }
  }

  void _removeKeeper(int index) {
    setState(() {
      _keepers.removeAt(index);
    });
  }

  void _deleteEntry() {
    // TODO: handle actual entry deletion logic
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('ENTRY CONFIG'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'DOOR ENTRY ID',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Text(
              'Door Keeper #3 | 10:42am',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              'DOOR KEEPER’S EMAIL',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _keeperController,
              decoration: InputDecoration(
                hintText: 'Some email address',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addKeeper,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addKeeper,
              child: const Text('Add keeper'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _keepers.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(_keepers[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeKeeper(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _deleteEntry,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
              child: const Text('Delete entry'),
            ),
          ],
        ),
      ),
    );
  }
}
