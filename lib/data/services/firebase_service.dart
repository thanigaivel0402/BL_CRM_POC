import 'dart:io';

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

    String audioUrl = await uploadImageToStorage("audioUrl", audioFile);

    DocumentReference documentReference = _fireStore
        .collection("users")
        .doc(uid)
        .collection("notes")
        .doc();
    note.id = documentReference.id;
    note.audioUrl = audioUrl;
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

  static Future<String> uploadImageToStorage(
    String childName,
    String filePath,
  ) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    final file = File(filePath);
    final fileName = file.uri.pathSegments.last;

    Reference ref = _storage
        .ref()
        .child(childName)
        .child(_auth.currentUser!.uid)
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
