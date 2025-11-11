import 'package:bl_crm_poc_app/data/services/auth_service.dart';
import 'package:bl_crm_poc_app/data/services/firebase_service.dart';
import 'package:bl_crm_poc_app/models/note.dart';
import 'package:bl_crm_poc_app/pages/recording_page.dart';
import 'package:bl_crm_poc_app/utils/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late Future<List<Note>> _notes;

  Future<List<Note>> _fetchNotes() async {
    await Future.delayed(const Duration(seconds: 1));
    return await FirebaseService.fetchNotes();
  }

  // 👇 Refresh logic
  Future<void> _refreshNotes() async {
    setState(() {
      _notes = _fetchNotes();
    });
  }

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
  void initState() {
    super.initState();
    _notes = _fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0072BC),
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
              onSelected: (value) async {
                if (value == 'logout') {
                  AuthService().signOut();
                  await AppPreferences.setLoggedIn(false);
                  context.push('/login');
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'logout', child: Text('Logout')),
              ],
            ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _refreshNotes,
        child: FutureBuilder<List<Note>>(
          future: _notes,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  '❌ Error loading notes. Check Firebase connection.',
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('📝 No notes yet.'));
            }

            // 🔎 Apply search filter
            var notes = snapshot.data!;

            if (_searchQuery.isNotEmpty) {
              notes = notes.where((note) {
                final title = (note.meetingWith).toString().toLowerCase();
                final content = (note.meetingType).toString().toLowerCase();
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
                  childAspectRatio: 0.8,
                ),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  // 🕓 Format timestamp
                  final timestamp = note.eventDate;
                  print("===timeStamp=====$timestamp===========");
                  String formattedDate = '';
                  if (timestamp != null) {
                    formattedDate = DateFormat(
                      'dd MMM yyyy, hh:mm a',
                    ).format(timestamp);
                  } else {
                    formattedDate = 'Unknown date';
                  }
                  return GestureDetector(
                    onTap: () {
                      context.push("/note-page", extra: note);
                    },
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.meetingWith,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              note.meetingType,
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
                                note.transcript,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                                maxLines: 4,
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
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0072BC),
        onPressed: () async {
          await showRecording();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  showRecording() async {
    bool hasPermission = await requestMicPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Microphone permission denied')));
    } else {
      await showDialog(
        context: context,
        builder: (context) {
          return RecordingPage();
        },
      );
    }
  }

  Future<bool> requestMicPermission() async {
    var status = await Permission.microphone.status;

    if (status.isGranted) {
      return true;
    } else {
      var result = await Permission.microphone.request();

      if (result.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }
}
