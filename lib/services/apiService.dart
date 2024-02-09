import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<int> sendDataToBackend(String? taskName, String? taskDescription, String? latitude, String? longitude, List<int>? fileBytes) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse('http://localhost:8080/api/tasks'));
    
    // Add task details as fields
    request.fields['taskName'] = taskName!;
    request.fields['taskDescription'] = taskDescription!;
    request.fields['latitude'] = latitude!;
    request.fields['longitude'] = longitude!;
    
    // Add file as a multipart file
    request.files.add(http.MultipartFile.fromBytes('file', fileBytes!, filename: 'filename.txt'));

    var response = await request.send();
    
    if (response.statusCode == 200) {
      print('Data sent to backend successfully!');
      return 1;
    } else {
      print('Failed to send data to backend. Status code: ${response.statusCode}');
      return 0;
    }
  } catch (e) {
    print('Error sending data to backend: $e');
    return 0;
  }  
}
