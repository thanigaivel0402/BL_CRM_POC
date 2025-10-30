// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Note {
   String id;
   String meetingWith;
   String meetingType;
  DateTime? eventDate;
  DateTime? eventEnd;
  String? audioUrl;
   String transcript;
  Map<String, dynamic>? summary;
  String? status;
  int? version;
  Note({
    required this.id,
    this.meetingWith = '',
    this.meetingType = '',
    required this.eventDate,
    this.eventEnd,
    this.audioUrl,
    required this.transcript,
    this.summary = const {
      'highlights': [],
      'decisions': [],
      'actionItems': [],
      'followUps': [],
      'summaryText': '',
    },
    this.status = 'draft',
    this.version = 1,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'meetingWith': meetingWith,
      'meetingType': meetingType,
      'eventDate': eventDate?.millisecondsSinceEpoch,
      'eventEnd': eventEnd?.millisecondsSinceEpoch,
      'audioUrl': audioUrl,
      'transcript': transcript,
      'summary': summary,
      'status': status,
      'version': version,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      meetingWith: map['meetingWith'] as String,
      meetingType: map['meetingType'] as String,
      eventDate: map['eventDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['eventDate'] as int) : null,
      eventEnd: map['eventEnd'] != null ? DateTime.fromMillisecondsSinceEpoch(map['eventEnd'] as int) : null,
      audioUrl: map['audioUrl'] != null ? map['audioUrl'] as String : null,
      transcript: map['transcript'] as String,
      summary: map['summary'] != null ? Map<String, dynamic>.from((map['summary'] as Map<String, dynamic>) ): null,
      status: map['status'] != null ? map['status'] as String : null,
      version: map['version'] != null ? map['version'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) => Note.fromMap(json.decode(source) as Map<String, dynamic>);
}
