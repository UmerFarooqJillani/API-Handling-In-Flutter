/*
SharedPreferences stores data as key–value pairs (like a small local database).
It’s great for non-sensitive tokens (like demo apps).
How it works:
  - Uses reqres.in (a free dummy API).
  - On login → saves token with SharedPreferences.
  - Fetches profile with that token.
  - On logout → removes token.
*/

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Token Demo (SharedPreferences)',
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    var url = Uri.parse('https://ticklearn.ai/api/AccountApi/login'); // Dummy API

    var response = await http.post(
      url,
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String token = data['sessionToken'];

      // ✅ Save token locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sessionToken', token);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful! Token saved.')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login (SharedPreferences)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text('Login')),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userData = 'Fetching profile...';

  Future<void> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('sessionToken');

    var url = Uri.parse('https://ticklearn.ai/api/AccountApi/profile/testuser@example.com'); // Dummy protected endpoint
    var response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    setState(() {
      userData = response.body;
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sessionToken');
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(userData),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: logout, child: Text('Logout')),
          ],
        ),
      ),
    );
  }
}
