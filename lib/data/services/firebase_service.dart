import 'dart:io';
import 'package:bl_crm_poc_app/data/services/cloud_services.dart';
import 'package:bl_crm_poc_app/models/note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  static Future<String> addNote(Note note, String audioFile) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var uid = _auth.currentUser!.uid;

    DocumentReference documentReference = _fireStore
        .collection("users")
        .doc(uid)
        .collection("notes")
        .doc();
    note.id = documentReference.id;
    String audioUrl = await uploadAudioToStorage(
      "audioUrls",
      audioFile,
      note.id,
    );

    note.audioUrl = audioUrl;
    await documentReference.set(note.toMap());
    print(
      "=========audioUrl=====${audioUrl}=====${note.id}=====$uid==========================",
    );
    await CloudService.transcribeAudioNote(uid, note.id, audioUrl);
    return "success";
  }

  static Future<String> editNote(Note note) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var uid = _auth.currentUser?.uid;
    DocumentReference reference = _fireStore
        .collection("users")
        .doc(uid)
        .collection("notes")
        .doc(note.id);
    reference.update({
      'meetingType': note.meetingType,
      'transcript': note.transcript,
    });
    return "Success";
  }

  static Future<List<Note>> fetchNotes() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var uid = _auth.currentUser?.uid;
    var notesRef = _fireStore
        .collection("users")
        .doc(uid)
        .collection("notes")
        .orderBy('eventDate', descending: true);

    QuerySnapshot snapShot = await notesRef.get();
    final notes = snapShot.docs
        .map((doc) => Note.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    return notes;
  }

  static String delete(Note note) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var uid = _auth.currentUser?.uid;
    DocumentReference reference = _fireStore
        .collection("users")
        .doc(uid)
        .collection("notes")
        .doc(note.id);
    reference.delete();
    return "success";
  }

  static Future<String> uploadAudioToStorage(
    String childName,
    String filePath,
    String noteId,
  ) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    final file = File(filePath);
    final fileName = file.uri.pathSegments.last;

    Reference ref = _storage
        .ref()
        .child(childName)
        .child(_auth.currentUser!.uid)
        .child(noteId)
        .child(fileName);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    debugPrint(
      "===============uploadImageToStorage==============================",
    );
    return downloadUrl;
  }
}
