import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddNoteScreen extends StatefulWidget {
  final String? noteId;
  final String? existingTitle;
  final String? existingContent;

  const AddNoteScreen({
    super.key,
    this.noteId,
    this.existingTitle,
    this.existingContent,
  });

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final notesRef = FirebaseFirestore.instance.collection('notes');

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.existingTitle ?? '';
    _contentController.text = widget.existingContent ?? '';
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) return;

    if (widget.noteId == null) {
      await notesRef.add({
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      await notesRef.doc(widget.noteId).update({
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveNote),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(hintText: 'Content'),
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
