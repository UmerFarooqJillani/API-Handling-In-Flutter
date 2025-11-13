/*
-> flutter_secure_storage: 
    - keeps data encrypted and safe — ideal for real apps.
    - It’s stored in a secure part of the device (Keychain on iOS, Keystore on Android).
*/

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() => runApp(MySecureApp());

class MySecureApp extends StatelessWidget {
  const MySecureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Token Demo (SecureStorage)',
      home: SecureLoginScreen(),
    );
  }
}

class SecureLoginScreen extends StatefulWidget {
  const SecureLoginScreen({super.key});

  @override
  State<SecureLoginScreen> createState() => _SecureLoginScreenState();
}

class _SecureLoginScreenState extends State<SecureLoginScreen> {
  final storage = FlutterSecureStorage();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    var url = Uri.parse('https://ticklearn.ai/api/AccountApi/login');

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

      // ✅ Save token securely
      await storage.write(key: 'sessionToken', value: token);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful! Token saved securely.')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SecureProfileScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login (SecureStorage)')),
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

class SecureProfileScreen extends StatefulWidget {
  const SecureProfileScreen({super.key});

  @override
  State<SecureProfileScreen> createState() => _SecureProfileScreenState();
}

class _SecureProfileScreenState extends State<SecureProfileScreen> {
  final storage = FlutterSecureStorage();
  String userData = 'Fetching secure profile...';

  Future<void> fetchProfile() async {
    String? token = await storage.read(key: 'sessionToken');

    var url = Uri.parse('https://ticklearn.ai/api/AccountApi/details/testuser@example.com');
    var response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    setState(() {
      userData = response.body;
    });
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
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
      appBar: AppBar(title: Text('Secure Profile')),
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
