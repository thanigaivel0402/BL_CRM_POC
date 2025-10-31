// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bl_crm_poc_app/data/services/firebase_service.dart';
import 'package:bl_crm_poc_app/models/note.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ignore: must_be_immutable
class NotePage extends StatefulWidget {
  Note note;

  NotePage({super.key, required this.note});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  late TextEditingController titleController;
  late TextEditingController descController;

  bool isEditable = false;

  @override
  void initState() {
    titleController = TextEditingController(text: widget.note.meetingType);
    descController = TextEditingController(text: widget.note.transcript);
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actionsPadding: EdgeInsets.only(right: screenHeight / 40),
        leading: Padding(
          padding: EdgeInsets.all(screenHeight / 40),
          child: GestureDetector(
            onTap: () {
              context.pop();
            },
            child: Icon(Icons.arrow_back, size: screenHeight / 40),
          ),
        ),
        actions: [
          isEditable
              ? TextButton(
                  style: ButtonStyle(),
                  onPressed: () {
                    setState(() {
                      isEditable = false;
                    });
                  },
                  child: Text("Cancel", style: TextStyle(color: Colors.blue)),
                )
              : InkWell(
                  onTap: () {
                    setState(() {
                      isEditable = true;
                    });
                  },
                  child: CustomIconButton(
                    icon: Icons.edit,
                    iconSize: screenHeight / 40,
                  ),
                ),
          SizedBox(width: 10),
          isEditable
              ? SizedBox()
              : InkWell(
                  onTap: () {
                    try {
                      FirebaseService.delete(widget.note);
                      context.pop();
                    } catch (e) {
                      debugPrint(e.toString());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Something Went Wrong ! Try Again"),
                        ),
                      );
                    }
                  },
                  child: CustomIconButton(
                    icon: Icons.delete_outline,
                    iconSize: screenHeight / 40,
                  ),
                ),
          SizedBox(width: 10),
          isEditable
              ? SizedBox()
              : InkWell(
                  onTap: () {},
                  child: CustomIconButton(
                    icon: Icons.share,
                    iconSize: screenHeight / 40,
                  ),
                ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(screenHeight / 40),
        child: Column(
          children: [
            TextFormField(
              enabled: isEditable,
              controller: titleController,
              cursorColor: Colors.black,
              style: TextStyle(
                color: Colors.black,
                fontSize: screenHeight / 30,
              ),
              decoration: InputDecoration(
                hintText: "Title",
                hintStyle: TextStyle(
                  fontSize: screenHeight / 30,
                  color: Colors.black38,
                ),
                border: InputBorder.none,
              ),
            ),

            TextFormField(
              enabled: isEditable,
              controller: descController,
              maxLines: 10,
              cursorColor: Colors.black,
              style: TextStyle(
                color: Colors.black,
                fontSize: screenHeight / 40,
              ),
              decoration: InputDecoration(
                hintText: "SubTitle",
                hintStyle: TextStyle(
                  fontSize: screenHeight / 40,
                  color: Colors.black38,
                ),
                border: InputBorder.none,
              ),
            ),

            isEditable
                ? GestureDetector(
                    onTap: () {
                      try {
                        widget.note.transcript = descController.text;
                        FirebaseService.editNote(widget.note);
                        context.pop();
                      } catch (e) {
                        debugPrint(e.toString());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Something Went Wrong ! Try Again"),
                          ),
                        );
                      }
                    },
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenHeight / 20,
                          vertical: screenHeight / 70,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenHeight / 40,
                          ),
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomIconButton extends StatelessWidget {
  IconData icon;
  double iconSize;

  CustomIconButton({super.key, required this.icon, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(31, 156, 151, 151),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(10),
      child: Icon(icon, size: iconSize),
    );
  }
}
