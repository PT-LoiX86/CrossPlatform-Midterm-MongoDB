import 'package:flutter/material.dart';

import '../../models/lecturer.dart';
import '../../services/lecturer_service.dart';
import '../../widgets/lecturer_profile_dialog.dart';
import '../widgets/lecturer_card.dart';
import 'lecturer_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.username, required this.onLogout});

  final String username;
  final VoidCallback onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Lecturer>> _lecturersFuture;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _lecturersFuture = LecturerService.getAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    debugPrint('Fetching lecturers from API...');

    final future = LecturerService.getAll();

    setState(() {
      _lecturersFuture = future;
    });

    try {
      final lecturers = await future;

      debugPrint('Lecturers retrieved: ${lecturers.length}');

      for (final lecturer in lecturers) {
        debugPrint('${lecturer.idgv} - ${lecturer.fullname}');
      }
    } catch (error) {
      debugPrint('Failed to reload lecturers: $error');
    }
  }

  Future<void> _openForm({Lecturer? lecturer}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => LecturerFormScreen(lecturer: lecturer)),
    );

    debugPrint('Form returned: $changed');

    if (changed == true && mounted) {
      debugPrint('Refreshing lecturer list...');
      await _reload();
    }
  }

  Future<void> _showProfile(Lecturer lecturer) async {
    await showDialog<void>(
      context: context,
      builder: (_) => LecturerProfileDialog(lecturer: lecturer),
    );
  }

  Future<void> _deleteLecturer(Lecturer lecturer) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete lecturer?'),
        content: Text(
          'Are you sure you want to delete ${lecturer.fullname}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await LecturerService.delete(lecturer.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lecturer deleted successfully.')),
      );
      _reload();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _logout() {
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lecturer Manager',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text(
              'ADMINISTRATION',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 1.4,
                color: Color(0xFF8295A7),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Account menu',
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'account',
                enabled: false,
                child: Text('Signed in as ${widget.username}'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sign out'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: Color(0xFFE6F2FC),
                child: Icon(Icons.person, size: 19, color: Color(0xFF1769AA)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 17, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lecturers',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF18344F),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'View and manage lecturer records.',
                    style: TextStyle(color: Color(0xFF71869A)),
                  ),
                  const SizedBox(height: 17),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) =>
                        setState(() => _query = value.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search by name or lecturer ID',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Lecturer>>(
                future: _lecturersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _ErrorState(
                      message: snapshot.error.toString(),
                      onRetry: _reload,
                    );
                  }

                  final lecturers = (snapshot.data ?? []).where((lecturer) {
                    return lecturer.fullname.toLowerCase().contains(_query) ||
                        lecturer.idgv.toLowerCase().contains(_query);
                  }).toList();

                  if (lecturers.isEmpty) {
                    return _EmptyState(
                      isSearching: _query.isNotEmpty,
                      onAdd: () => _openForm(),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _reload(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 100),
                      itemCount: lecturers.length,
                      itemBuilder: (context, index) {
                        final lecturer = lecturers[index];
                        return LecturerCard(
                          lecturer: lecturer,
                          onTap: () => _showProfile(lecturer),
                          onEdit: () => _openForm(lecturer: lecturer),
                          onDelete: () => _deleteLecturer(lecturer),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add lecturer'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isSearching, required this.onAdd});

  final bool isSearching;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.groups_2_outlined,
              size: 58,
              color: Color(0xFF9CB6CC),
            ),
            const SizedBox(height: 14),
            Text(
              isSearching ? 'No matching lecturers' : 'No lecturers yet',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF18344F),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSearching
                  ? 'Try another name or lecturer ID.'
                  : 'Add the first lecturer to get started.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF71869A)),
            ),
            if (!isSearching) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add lecturer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: Color(0xFFD08A35),
            ),
            const SizedBox(height: 12),
            const Text(
              'Could not load lecturers',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF71869A)),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
