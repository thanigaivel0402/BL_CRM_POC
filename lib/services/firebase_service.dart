import 'package:bl_crm_poc_app/models/note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  static Future<String> addNote(Note note) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var uid = _auth.currentUser?.uid;
    DocumentReference documentReference = _fireStore
        .collection("users")
        .doc(uid)
        .collection("notes")
        .doc();
    note.id = documentReference.id;
    documentReference.set(note.toJson());
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
      'audioUrl': note.audioUrl,
      'transcript': note.transcript,
    });
    return "Success";
  }
}
