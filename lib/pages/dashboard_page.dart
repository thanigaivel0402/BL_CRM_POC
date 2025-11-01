import 'package:bl_crm_poc_app/data/services/firebase_service.dart';
import 'package:bl_crm_poc_app/models/note.dart';
import 'package:bl_crm_poc_app/pages/note_page.dart';
import 'package:bl_crm_poc_app/pages/recording_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- added for user info & sign out

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

  // Sign out logic
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to login route (update route name if different)
      context.go('/login');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notesRef = FirebaseFirestore.instance.collection('users').doc(
        FirebaseAuth.instance.currentUser!.uid).collection('notes');

    // get current user info (may be null)
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Guest User';
    final email = user?.email ?? 'No email';
    final photoUrl = FirebaseAuth.instance.currentUser?.photoURL;

    return Scaffold(
      // Add a Drawer that acts as the "menu bar" with profile + sign out
      drawer: Drawer(
        
        backgroundColor: Color(0xFFF3F5FF),
        child: Column(
          children: [
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(
            color: Color(0xFF1768B3), 
          ),
          accountName: Text(displayName), 
          accountEmail: Text(email),
          currentAccountPicture: CircleAvatar(
            backgroundColor: theme.colorScheme.onPrimary,
            child: ClipOval(
          child: photoUrl != null
              ? Image.network(
              photoUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              // show initials if load fails (429, network, etc)
              errorBuilder: (context, error, stackTrace) {
                return Center(
              child: Text(
                (displayName.isNotEmpty ? displayName[0] : 'G')
                .toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
                );
              },
            )
              : Center(
              child: Text(
                (displayName.isNotEmpty ? displayName[0] : 'G')
                .toUpperCase(),
                style: TextStyle(
              fontSize: 24,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile'),
          subtitle: Text(displayName),
          onTap: () {
            // Optional: navigate to profile page or just close drawer
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          leading: const Icon(Icons.email),
          title: const Text('Email'),
          subtitle: Text(email),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () async {
          Navigator.of(context).pop(); // close drawer first
          await _signOut();
            },
          ),
        ),
          ],
        ),
      ),

      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF1768B3),
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
        ],
      ),

      // ✅ Real-time Firestore Stream
      body: FutureBuilder<List<Note>>(
        future: FirebaseService.fetchNotes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('❌ Error loading notes. Check Firebase connection.'),
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
              final title = (note.meetingWith ?? '').toString().toLowerCase();
              final content = (note.meetingType ?? '').toString().toLowerCase();
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
                final timestamp = note.eventDate;
                
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotePage(note: note)
                      ),
                    );
                  },
                  child: Card(
                    
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color:Color(0xF3F5FFFF) ,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.meetingWith ?? 'Untitled',
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
                              note.meetingType?? '',
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
                              timestamp != null
                                  ? DateFormat.yMMMd().add_jm().format(timestamp)
                                  : 'No Date',
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
        backgroundColor: Color(0xFF1768B3),
        foregroundColor: Colors.white,
        onPressed: () async {
          await showRecording();
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
