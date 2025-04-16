import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedLanguage = 'English';

  final Map<String, String> languages = {
    'English': '🇬🇧',
    'French': '🇫🇷',
    'German': '🇩🇪',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey[200],
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .orderBy('createdAt', descending: true)
                    .limit(3)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmpty();
                  }

                  final events = snapshot.data!.docs;

                  return ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const Text(
                        'Your Events',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...events.map((doc) {
                        final event = doc.data() as Map<String, dynamic>;
                        final title = event['title'] ?? 'Untitled';
                        final start = event['startTime'] != null
                            ? DateTime.parse(event['startTime']).toLocal()
                            : null;

                        return Card(
                          child: ListTile(
                            title: Text(title),
                            subtitle: Text(
                              start != null
                                  ? 'Starts: ${start.toString()}'
                                  : 'No time set',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.pushNamed(context, '/events');
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/events');
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('View All Events'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/no_events.png',
          height: 160,
        ),
        const SizedBox(height: 24),
        const Text(
          'NO EVENTS YET',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: 220,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/create-event');
            },
            icon: const Icon(Icons.add),
            label: const Text(
              'Create New Event',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.indigo[900],
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.close, color: Colors.white),
              Text(
                'PopPlans',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(width: 24),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Log out'),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Change language',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedLanguage,
                icon: const Icon(Icons.keyboard_arrow_down),
                onChanged: (value) {
                  setState(() {
                    selectedLanguage = value!;
                  });
                },
                items: languages.keys.map((String key) {
                  return DropdownMenuItem<String>(
                    value: key,
                    child: Row(
                      children: [
                        Text(languages[key]!),
                        const SizedBox(width: 10),
                        Text(key),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
