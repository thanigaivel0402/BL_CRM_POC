import 'package:cloud_functions/cloud_functions.dart';

class CloudService {
  static Future<void> transcribeAudioNote(
    String userId,
    String noteId,
    String audioUrl,
  ) async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'transcribeExistingAudio',
    );

    print("Calling transcribeExistingAudio with:");
    print("userId: $userId");
    print("noteId: $noteId");
    print("audioUrl: $audioUrl");

    try {
      final result = await callable.call({
        'userId': userId,
        'noteId': noteId,
        'audioUrl': audioUrl,
      });

      print("Transcription completed: ${result.data['transcript']}");
    } catch (e) {
      print("Error: $e");
    }
  }
}
