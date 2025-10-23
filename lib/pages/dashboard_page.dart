import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bl_crm_poc_app/pages/add_note_screen.dart'; // Adjust path if needed

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final notesRef = FirebaseFirestore.instance.collection('notes');

    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      // body:
      //  StreamBuilder<QuerySnapshot>(
      //   stream: notesRef.orderBy('timestamp', descending: true).snapshots(),
      //   builder: (context, snapshot) {
      //     if (!snapshot.hasData)
      //       return const Center(child: CircularProgressIndicator());
      //     final notes = snapshot.data!.docs;

      //     if (notes.isEmpty) return const Center(child: Text('No notes yet.'));

      //     return ListView.builder(
      //       itemCount: notes.length,
      //       itemBuilder: (context, index) {
      //         final note = notes[index];
      //         return Card(
      //           margin: const EdgeInsets.all(8),
      //           child: ListTile(
      //             title: Text(note['title'] ?? ''),
      //             subtitle: Text(
      //               note['content'] ?? '',
      //               maxLines: 2,
      //               overflow: TextOverflow.ellipsis,
      //             ),
      //             trailing: IconButton(
      //               icon: const Icon(Icons.delete, color: Colors.red),
      //               onPressed: () => notesRef.doc(note.id).delete(),
      //             ),
      //             onTap: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (_) => AddNoteScreen(
      //                     noteId: note.id,
      //                     existingTitle: note['title'],
      //                     existingContent: note['content'],
      //                   ),
      //                 ),
      //               );
      //             },
      //           ),
      //         );
      //       },
      //     );
      //   },
      // ),
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
}
