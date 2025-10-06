import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.29.78:3003/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Login failed');
    }
  }

  Future<Map<String, dynamic>> signup(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password, 'name': name}),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Signup failed');
    }
  }

  Future<Map<String, dynamic>> getDashboard(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get dashboard data');
    }
  }

  Future<List<dynamic>> getRecords(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/records'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get records');
    }
  }

  Future<Map<String, dynamic>> createRecord(String token, String title, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/records'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'title': title, 'data': data}),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create record');
    }
  }

  Future<Map<String, dynamic>> updateRecord(String token, int id, String title, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/records/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'title': title, 'data': data}),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update record');
    }
  }

  Future<void> deleteRecord(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/records/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete record');
    }
  }

  Future<Map<String, dynamic>> uploadFile(String token, File file, Map<String, dynamic> metadata) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['metadata'] = json.encode(metadata);
    
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      return json.decode(responseBody);
    } else {
      throw Exception('Upload failed');
    }
  }
}