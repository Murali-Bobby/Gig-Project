import 'dart:convert';
import 'dart:html';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gig_project/services/apiService.dart';
import 'package:gig_project/pages/map.dart';
import 'package:latlong2/latlong.dart';

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
  bool isFileUploaded = false;
  bool isLocationSelected = false;
  FilePickerResult? result;
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
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Map()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: CircleBorder(),
              primary: Colors.white,
            ),
            child: Ink(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(Icons.location_on),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ElevatedButton(
            onPressed: () async {
                result = await FilePicker.platform.pickFiles();

                if (result != null) {
                  PlatformFile file = result!.files.first;
                  print("File Name: ${file.name}");
                  setState(() {
                    isFileUploaded = true;
                  });

                } else {
                  // User canceled the file picker
                }
              },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: CircleBorder(),
              primary: Colors.white,
            ),
            child: Ink(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(Icons.upload, color: isFileUploaded ? Colors.green : null),
              ),
            ),
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
    // print("Input is recoreded : ${message.text}");

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
          // _sendMessage("Please select the location on the map. You can access the map using the navigation button present in the top left cornor");
          
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Map(),
              ),
            ).then((selectedLocation) {
              if (selectedLocation != null) {
                // Handle the selected location received from the map screen
                _handleSelectedLocation(selectedLocation);
              }
            });

          // _createTask();
        }
      }
    }
  }

  _handleSelectedLocation(LatLng selectedLocation) {
    print("Latitude: ${selectedLocation.latitude}, Longitude: ${selectedLocation.longitude}, Task Name: $_taskName, Task Description: $_taskDescription");
  // _sendMessage("Latitude: ${selectedLocation.latitude}, Longitude: ${selectedLocation.longitude}, Task Name: $_taskName, Task Description: $_taskDescription");
  _createTask(selectedLocation);
 
}

  void _startTaskCreation() {
    setState(() {
      taskCreationStarted = true;
      _taskName = null;
      _taskDescription = null;
    });
    _sendMessage("Type the name of the task:");
  }

  Future<void> _createTask(LatLng selectedLocation) async {
    int result = await sendDataToBackend(_taskName, _taskDescription, selectedLocation.latitude.toString(), selectedLocation.longitude.toString());
    if (result == 1) {
      _sendMessage("Task created successfully:\nName: $_taskName\nDescription: $_taskDescription\nLatitude:${selectedLocation.latitude.toString()}\nLongitude${selectedLocation.longitude.toString()}");
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
