import 'package:flutter/material.dart';

import 'services/mongo_service.dart';

void main() {
  runApp(const MaterialApp(home: MongoTestPage()));
}

class MongoTestPage extends StatefulWidget {
  const MongoTestPage({super.key});

  @override
  State<MongoTestPage> createState() => _MongoTestPageState();
}

class _MongoTestPageState extends State<MongoTestPage> {
  String result = 'Not tested yet';
  bool loading = false;

  Future<void> testConnection() async {
    setState(() {
      loading = true;
      result = 'Testing...';
    });

    try {
      await MongoService.addUser('Flutter connection test ${DateTime.now()}');

      final users = await MongoService.getUsers();

      setState(() {
        result =
            'SUCCESS!\n'
            'POST: User created\n'
            'GET: ${users.length} users retrieved\n'
            'Latest: ${users.first['name']}';
      });
    } catch (e) {
      setState(() {
        result = 'ERROR: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MongoDB Test')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: loading ? null : testConnection,
                child: const Text('Test Connection'),
              ),
              const SizedBox(height: 20),
              Text(result),
            ],
          ),
        ),
      ),
    );
  }
}
