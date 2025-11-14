import 'dart:io';
import 'package:bl_crm_poc_app/data/services/firebase_service.dart';
import 'package:bl_crm_poc_app/models/note.dart';
import 'package:bl_crm_poc_app/utils/assets.dart';
import 'package:bl_crm_poc_app/utils/validations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  final audioRecorder = AudioRecorder();
  bool isRecording = false;
  String filePath = '';

  bool isSaving = false;

  late GlobalKey<FormState> _formKey;

  late TextEditingController meetingWithController;
  late TextEditingController meetingTypeController;

  @override
  void initState() {
    super.initState();
    meetingWithController = TextEditingController();
    meetingTypeController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        width: double.infinity,
        padding: EdgeInsets.all(screenHeight / 80),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                validator: Validations.validateTitle,
                textAlign: TextAlign.center,

                controller: meetingWithController,
                style: TextStyle(
                  fontSize: screenHeight / 40,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: "Meeting With",
                  hintStyle: TextStyle(
                    fontSize: screenHeight / 40,
                    color: Colors.black26,
                  ),
                  border: InputBorder.none,
                ),
              ),
              TextFormField(
                validator: Validations.validateSubTitle,
                controller: meetingTypeController,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenHeight / 60,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    fontSize: screenHeight / 60,
                    color: Colors.black26,
                  ),
                  hintText: "Meeting Type",
                  border: InputBorder.none,
                ),
              ),

              Container(
                height: screenHeight / 7,
                width: screenHeight / 7,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: Lottie.asset(
                  Assets.microphoneRecord,
                  fit: BoxFit.contain,
                  animate: isRecording,
                ),
              ),
              SizedBox(height: screenHeight / 80),
              isSaving
                  ? Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 5),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.pop();
                          },
                          child: Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: isRecording
                              ? stopRecording
                              : startRecording,
                          child: isRecording
                              ? Row(
                                  children: [Text("Pause"), Icon(Icons.pause)],
                                )
                              : Row(
                                  children: [
                                    Text("Start"),
                                    Icon(Icons.play_arrow),
                                  ],
                                ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              isSaving = true;
                            });
                            await save();
                            setState(() {
                              isSaving = false;
                            });
                          },
                          child: Text("Save"),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> startRecording() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    filePath = '${appDir.path}/my_record.wav';
    await audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: filePath,
    );
    setState(() => isRecording = true);
  }

  Future<void> stopRecording() async {
    filePath = await audioRecorder.stop() ?? '';
    print("=====filePath : $filePath==============================");
    setState(() {
      isRecording = false;
    });
  }

  save() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (filePath.isNotEmpty) {
        print("==============save================================");
        Note note = Note(
          id: "",
          eventDate: DateTime.now(),
          transcript: "",
          meetingType: meetingTypeController.text,
          meetingWith: meetingWithController.text,
        );
        try {
          await FirebaseService.addNote(note, filePath);
          await FirebaseService.fetchNotes();
          context.pop();
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
          context.pop();
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Record Audio")));
      }
    }
  }
}
