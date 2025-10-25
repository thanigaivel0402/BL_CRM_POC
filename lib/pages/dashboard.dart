import 'package:bl_crm_poc_app/pages/recording_page.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showRecording();
        },
        child: Icon(Icons.add),
      ),
    );
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
