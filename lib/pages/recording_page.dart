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

  late GlobalKey<FormState> _formKey;

  late TextEditingController titleController;
  late TextEditingController subTitleController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    subTitleController = TextEditingController();
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

                controller: titleController,
                style: TextStyle(
                  fontSize: screenHeight / 40,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: "Title",
                  hintStyle: TextStyle(
                    fontSize: screenHeight / 40,
                    color: Colors.black26,
                  ),
                  border: InputBorder.none,
                ),
              ),
              TextFormField(
                validator: Validations.validateSubTitle,
                controller: subTitleController,
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
                  hintText: "SubTitle",
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: isRecording ? stopRecording : startRecording,
                    child: Text(isRecording ? 'Pause' : 'Start'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await save();
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
    filePath = '${appDir.path}/my_record.m4a';
    await audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
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
          meetingType: titleController.text,
          meetingWith: subTitleController.text,
        );
        try {
          await FirebaseService.addNote(note, filePath);
        } catch (e) {
          print('========${e.toString()}================');
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Record Audio")));
      }
    }
  }
}
