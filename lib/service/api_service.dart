import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'http://192.168.1.17:8000/api'; // Update with your API base URL
  


  Future<String?> register(String name, String email, String password, String passwordConfirmation) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveToken(data['token']);
      return data['token'];
    } else {
      final errors = json.decode(response.body)['errors'];
      return Future.error(errors);
    }
  }



  Future<String> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

   try {
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'email': email,
      'password': password,
    },
  );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        String token = data['token']['id'].toString(); // Adjust this to match your token structure
        int userId = data['user']['id'];

      // Enregistrez le token et l'ID utilisateur dans SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setInt('userId', userId);
        return token;
      } else {
        throw Exception('Failed to log in');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Failed to connect to the server');
    }
  }



  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
