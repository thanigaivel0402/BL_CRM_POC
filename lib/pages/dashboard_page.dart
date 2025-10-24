import 'package:flutter/material.dart';
import 'package:bl_crm_poc_app/pages/add_note_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _startSearch() {
    setState(() => _isSearching = true);
  }

  void _cancelSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final notesRef = FirebaseFirestore.instance.collection('notes');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: !_isSearching
            ? const Text('My Notes')
            : Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  cursorColor: theme.colorScheme.primary,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Search notes...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (query) {
                    debugPrint('Search query: $query');
                    // TODO: Filter notes here
                  },
                ),
              ),
        actions: [
          if (!_isSearching)
            IconButton(icon: const Icon(Icons.search), onPressed: _startSearch)
          else
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: _cancelSearch,
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          if (!_isSearching)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'settings') {
                  debugPrint('Settings selected');
                } else if (value == 'sort by created') {
                  debugPrint('Sort by time created');
                } else if (value == 'sort by edited') {
                  debugPrint('Sort by time edited');
                } else if (value == 'logout') {
                  debugPrint('Logout selected');
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'settings', child: Text('Settings')),
                PopupMenuItem(
                  value: 'sort by created',
                  child: Text('Sort by time created'),
                ),
                PopupMenuItem(
                  value: 'sort by edited',
                  child: Text('Sort by time edited'),
                ),
                PopupMenuItem(value: 'logout', child: Text('Logout')),
              ],
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notesRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading notes'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var notes = snapshot.data!.docs;

          // Apply search filter if any
          if (_searchQuery.isNotEmpty) {
            notes = notes.where((note) {
              final title = (note['title'] ?? '').toString().toLowerCase();
              final content = (note['content'] ?? '').toString().toLowerCase();
              return title.contains(_searchQuery) ||
                  content.contains(_searchQuery);
            }).toList();
          }

          if (notes.isEmpty) {
            return const Center(child: Text('No notes yet.'));
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(note['title'] ?? ''),
                  subtitle: Text(
                    note['content'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => notesRef.doc(note.id).delete(),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddNoteScreen(
                          noteId: note.id,
                          existingTitle: note['title'],
                          existingContent: note['content'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddNoteScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
