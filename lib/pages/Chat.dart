import 'dart:convert';
import 'dart:html';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gig_project/services/apiService.dart';
import 'package:gig_project/pages/map.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final ChatUser _chatUser = ChatUser(id: "1", firstName: "Murali", lastName: "Bobby");
  final ChatUser _currOppUser = ChatUser(id: "2", firstName: "Chat", lastName: "Bot");

  List<ChatMessage> _messages = <ChatMessage>[];
  bool taskCreationStarted = false;
  String? _taskName;
  String? _taskDescription;

  @override
  void initState() {
    super.initState();
    _sendMessage("Type 'new task' to start creating a new task.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Map()),
              );
            },
            child: CircleAvatar(
              child: Icon(Icons.location_on),
              radius: 20.0,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ElevatedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles();

                if (result != null) {
                  PlatformFile file = result.files.first;
                  print("File Name: ${file.name}");
                } else {
                  // User canceled the file picker
                }
              },
              child: Icon(Icons.upload),
            ),
          ),
        ],
        title: const Text("Task Creator", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(0, 166, 126, 1),
      ),
      body: DashChat(
        messageOptions: const MessageOptions(
          currentUserContainerColor: Colors.black,
          containerColor: Color.fromRGBO(0, 166, 126, 1),
          textColor: Colors.white,
        ),
        currentUser: _chatUser,
        onSend: (ChatMessage message) {
          _handleUserResponse(message);
        },
        messages: _messages,
      ),
    );
  }

  Future<void> _handleUserResponse(ChatMessage message) async {
    setState(() {
      _messages.insert(0, message);
    });
    print("Input is recoreded : ${message.text}");

    if(message.text.toLowerCase() == 'end'){
      _resetState();
      _messages.clear();
        _sendMessage("Please Type 'new task' to start creating a new task.");
    } else{

      if (!taskCreationStarted) {
        if (message.text.toLowerCase() == 'new task') {
          _startTaskCreation();
        } else {
          _sendMessage("Please Type 'new task' to start creating a new task.");
        }
      } 
      else {
        if (_taskName == null) {
          _taskName = message.text;
          _sendMessage("Please provide a description for the task '$_taskName'");
        } else if (_taskDescription == null) {
          _taskDescription = message.text;
          _createTask();
        }
      }
    }
  }

  void _startTaskCreation() {
    setState(() {
      taskCreationStarted = true;
      _taskName = null;
      _taskDescription = null;
    });
    _sendMessage("Type the name of the task:");
  }

  Future<void> _createTask() async {
    int result = await sendDataToBackend(_taskName, _taskDescription);
    if (result == 1) {
      _sendMessage("Task created successfully:\nName: $_taskName\nDescription: $_taskDescription");
      _sendMessage("Type 'new task' to create another task or type 'end' to complete the task creation process.");
      _resetState();
    } else {
      _sendMessage("Oopss :( Failed to create task. Please try again");
      _taskName = null;
      _taskDescription = null;
      _startTaskCreation();
    }
    
  }

  void _sendMessage(String text) {
    final responseMessage = ChatMessage(
      text: text,
      user: _currOppUser,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, responseMessage);
    });
  }

  void _resetState() {
    setState(() {
      taskCreationStarted = false;
      _taskName = null;
      _taskDescription = null;
    });
  }
}
