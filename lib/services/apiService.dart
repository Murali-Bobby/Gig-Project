import 'package:http/http.dart' as http;
import 'dart:convert';

Future<int> sendDataToBackend(String? taskName, String? taskDescription) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/tasks'), 
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'taskName': taskName,
        'taskDescription': taskDescription,
      }),
    );

    if (response.statusCode == 200) {
      print('Data sent to backend successfully!');
      return 1;
    } else {
      print('Failed to send data to backend. Status code: ${response.statusCode}');
      return 0;
    }
  } catch (e) {
    print('Error sending data to backend: $e');
  }  

  return 0;  
}
