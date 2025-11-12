## What is a Header in an API?
- In an API (Application Programming Interface), a header is a part of the HTTP request or response that contains extra information (metadata) about the request or the data being sent.
- Headers are like labels on a parcel, they tell the server how to interpret or handle the data inside.
### Common Types of API Headers:<br>
Header Name     ->      Purpose<br>
`Content-Type`  ->  Defines the format of data being sent (e.g., JSON, text, form-data)<br>
`Accept`        ->  Tells the server what data format client expects in response<br>
`Authorization` ->  Sends a token or credentials for authentication<br>
`User-Agent`    -> 	Describes the client app (optional)<br>
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  var url = Uri.parse('https://api.example.com/users');

  var response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json', // Data type
      'Accept': 'application/json',       // Expected response format
      'Authorization': 'Bearer YOUR_TOKEN_HERE', // Auth token (optional)
    },
  );

  print(response.statusCode);
  print(response.body);
}
```
- Headers are passed as a `Map<String, String>`.
- They travel with the HTTP request to the server.
- The server checks the headers before sending a response.
## What is a Token in an API?
- A Token is a unique digital key issued by a server after successful login or authentication.
- It’s used to identify and authorize a user for further requests.
- Think of it as an entry pass, once you log in, the server gives you a token.
- You use that token for every next request to prove your identity.
### Common Types of Tokens:
- `JWT (JSON Web Token)`
    - Most popular type, secure and encoded (Base64).
- `Bearer Token`
    - Token sent in the **Authorization** header, prefixed by the word `Bearer`.
- `API Key`
    - Static token used to authenticate apps (not users).
## How and When Tokens Are Used
### Step 1: `User Logs In`
```dart
var loginResponse = await http.post(
  Uri.parse('https://api.example.com/login'),
  body: jsonEncode({'email': 'test@gmail.com', 'password': '123456'}),
  headers: {'Content-Type': 'application/json'},
);

var data = jsonDecode(loginResponse.body);
String token = data['token']; // <-- server sends a token back
```
#### Explanation:
- The user sends credentials.
- The server verifies them.
- The server returns a token (e.g., JWT(JSON Web Token)).
### Step 2: `Use Token in Future Requests`
- Once you have the token, you send it with every API request:
```dart
var response = await http.get(
  Uri.parse('https://api.example.com/profile'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token', // attach token
  },
);
```
#### Explanation:
- You’re telling the server, `I’m already logged in, here’s my token verify me.`
- The server checks the token:
    - If valid, it allows access.
    - If expired/invalid, it returns 401 Unauthorized.
## When to Use Tokens
1. Scenario
    - Public data (e.g., news list)
    - Token Needed?
        - No	
    - Example
        - Anyone can access

2. Scenario
    - Private data (e.g., user profile, cart, payment)
    - Token Needed?
        - Yes
    - Example
        - Needs authentication	
3. Scenario
    - Login or signup	
    - Token Needed?
        - No	
    - Example
        - You don’t have a token yet
5. Scenario
    - After login	
    - Token Needed?
        - Yes	
    - Example
        - For all authenticated actions
