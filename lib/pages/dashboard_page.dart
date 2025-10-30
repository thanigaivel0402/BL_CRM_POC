import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:bl_crm_poc_app/pages/add_note_screen.dart';

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
            ? const Text('My Notes', style: TextStyle(color: Colors.white))
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
                    setState(() {
                      _searchQuery = query.trim().toLowerCase();
                    });
                  },
                ),
              ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: _startSearch,
            )
          else
            TextButton(
              onPressed: _cancelSearch,
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          if (!_isSearching)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'logout') {
                  // TODO: Implement logout logic
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'logout', child: Text('Logout')),
              ],
            ),
        ],
      ),

      // ✅ Real-time Firestore Stream
      body: StreamBuilder<QuerySnapshot>(
        stream: notesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('❌ Error loading notes. Check Firebase connection.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('📝 No notes yet.'));
          }

          // 🔎 Apply search filter
          var notes = snapshot.data!.docs;
          if (_searchQuery.isNotEmpty) {
            notes = notes.where((note) {
              final title = (note['title'] ?? '').toString().toLowerCase();
              final content = (note['content'] ?? '').toString().toLowerCase();
              return title.contains(_searchQuery) ||
                  content.contains(_searchQuery);
            }).toList();
          }

          // 📱 Show Grid View
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // two per row
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                // 🕓 Format timestamp
                final timestamp = note['time'];
                String formattedDate = '';
                if (timestamp != null && timestamp is Timestamp) {
                  formattedDate = DateFormat(
                    'dd MMM yyyy, hh:mm a',
                  ).format(timestamp.toDate());
                } else {
                  formattedDate = 'Unknown date';
                }
                return GestureDetector(
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
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.amber.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note['title'] ?? 'Untitled',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              note['content'] ?? '',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                              maxLines: 6,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
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
