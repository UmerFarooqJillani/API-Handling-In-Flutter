# <p align="center"> manage_sessions_in_app </p>

## Scenario:
- When a user logs in to your app (using username/password), the server gives back a `token`. A small key that says:
    - **This user is verified. Let them access private data.**<br>
- If we don’t save this token, the user would have to log in again every time the app restarts.
    - **So we store the token locally on the user’s device.**<br>
More About Token Visit: [Token Info](https://github.com/UmerFarooqJillani/API-Handling-In-Flutter/blob/78fd3a78046aacf9c774e319199743942c6b880c/Interview%20Q_A/Header%2C%20Token%20in%20API's.md)

## Where Tokens Are Stored in Flutter<br>
In Flutter, you have two common ways:
1. **`shared_preferences` (SharedPreferences):** When token is not highly sensitive (e.g., demo app, learning project)
2. **`flutter_secure_storage` (Secure Storage):** When token must be protected (e.g., real production app, payment app)
### SharedPreferences (Simple Way)
- This is like a small key-value storage on your phone.
    - Think of it like a `mini database` inside your phone.
    - You can save, get, or delete data easily.
#### Example: Saving and Using a Token in Flutter
1. Login and Save Token
    - When the user logs in successfully, the server gives a token (like abc123xyz).
    - You send login details to the server.
    - The server verifies and returns a token.
    - You save that token locally using SharedPreferences.
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> loginUser(String email, String password) async {
  var url = Uri.parse('https://api.example.com/login');

  var response = await http.post(
    url,
    body: jsonEncode({'email': email, 'password': password}),
    headers: {'Content-Type': 'application/json'},
  );

  // Convert the response body into JSON
  var data = jsonDecode(response.body);

  // Suppose the token is returned as "token": "abc123"
  String token = data['token'];

  // ✅ Save token for later use
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('token', token);

  print('Token saved: $token');
}
```
2. Use the Token for Other Requests
    - Once logged in, you don’t need to send your email/password again.
    - Just send the token in your request headers.
    - The token proves to the server that this request is from a logged-in user.
    - The server checks your token and returns private data (like your name, email, etc.).
```dart
Future<void> getUserProfile() async {
  final prefs = await SharedPreferences.getInstance();

  // Get saved token
  String? token = prefs.getString('token');

  // Send GET request with token in headers
  var response = await http.get(
    Uri.parse('https://api.example.com/profile'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // 🪙 Token used here
    },
  );

  print('Profile response: ${response.body}');
}
```
3. Logout (Remove Token)
    - Now the user must log in again to get a new token.
```dart
Future<void> logoutUser() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
  print('Token removed, user logged out.');
}
```
### Secure Storage (For Real Apps)
- If you’re building a real production app, use `flutter_secure_storage`, it encrypts data inside the phone so no one can read the token even if the app files are accessed.
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// Save
await storage.write(key: 'token', value: token);

// Read
String? token = await storage.read(key: 'token');
```
## Step by Step (Summary)
1. Login
    - User enters credentials and gets token from API
2. Save Token
    - Store it using SharedPreferences or SecureStorage
3. Use Token
    - Send it in headers (Authorization: Bearer token) for every private API
4. Logout
    - Delete token from storage so user must log in again

`In Flutter, we can store API tokens using either SharedPreferences (simple key-value storage) or SecureStorage (encrypted storage).`

`SharedPreferences is fine for normal apps, but SecureStorage should be used when security matters, for example, when handling authentication tokens, payments, or user credentials.`

`A token is a unique key that the server gives after login, used to prove who the user is. We store this token using SharedPreferences or SecureStorage so that we can reuse it for future API calls without asking the user to log in again.`