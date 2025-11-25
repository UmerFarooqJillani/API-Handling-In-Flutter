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

## `flutter_secure_storage` Used to store Token
- Under the hood, this uses:
    - **Android:** EncryptedSharedPreferences / Keystore
    - **iOS:** Keychain
### Why Apps Use Two Tokens (Access Token + Refresh Token)
- Modern apps never use only ONE token.
- They always use two tokens because each token has a very specific job.
### Access Token (Short-Live Token)
- Used for: Calling APIs (e.g. /get-user, /update-profile)
- Lifetime: Usually short (10 mins, 15 mins, 1 hour)
- Where sent: In every API request → Authorization: Bearer <token>
- Why short?
    - If this token gets stolen, hacker can only use it for a small time
    - Very safe for API calls
    - Adds security layer
- So, access token = key to APIs
- But expires quickly → that’s good for security.
### Refresh Token — Long-Live Token
- Used for: Getting a new access token when it expires
- Lifetime: Typically long (7 days, 30 days, 90 days)
- Where sent: Only to /refresh endpoint
- Stored securely: In encrypted storage (like flutter_secure_storage)
- Never sent on every API request
### Think of it like:
- **Access Token** = house door key (use daily but expires)
- **Refresh Token** = master key (kept very safe, used rarely)
### Why NOT use access token alone?
- If access token expires → the app will stop working instantly.
- Example:
    - User logs in
    - Access token (1 hour) is saved
    - After 1 hour → user tries to open Home screen → API says:
    ```dart
    401 Unauthorized → token expired
    ```
- Without **refresh token** → user must login again manually
    - Bad user experience
    - All users forced to login repeatedly
    - Not production-ready
### Why refresh token is needed<br>
- When access token expires:
    - Your app silently calls → /auth/refresh
    - Backend returns a new access token
    - User continues using app without knowing anything
- This is called Silent Authentication.
- Apps like `Facebook`, `Instagram`, `WhatsApp` all use this.
### Example Flow (Real World)
1. User logs in
    - Server gives:
        - accessToken = 1 hour
        - refreshToken = 30 days
2. User uses app all day:
    - Access token is automatically refreshed every time it expires.
3. After 30 days:
    - Refresh token also expires → user must login again
- **This keeps:**
    - The app secure
    - The user logged in smoothly
    - Hackers unable to misuse stolen tokens
```dart
await _storage.write(key: _keyAccessToken, value: accessToken);
await _storage.write(key: _keyRefreshToken, value: refreshToken);
```

