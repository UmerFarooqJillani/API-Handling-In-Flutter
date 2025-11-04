# <p align="center"> API Handling In Flutter </p>

## What is an API?
- API stands for Application Programming Interface.
- It’s like a messenger between your app and the server.
- It allows your app to send requests (ask for data or send data) and receive responses (the data from the server).
- An API (Application Programming Interface), is a set of defined rules and protocols that allow different software applications to communicate with each other. 
- It acts as an intermediary, enabling one piece of software to request services or data from another, without needing to understand the internal workings of that other system. 
## Why we use APIs?
- Cannot store everything locally (e.g., stories, profiles, updates).
- Needs real-time data from the internet (like weather, posts, videos).
- Needs to send data (login, upload, chat messages, etc.).
- **Example:**
    - You press “Login” → Flutter sends your email/password to server via API → server verifies → returns user info.
## Types of APIs
1. REST API
    - Most common; uses HTTP methods like GET, POST, PUT, DELETE
    - **Example:** `https://api.example.com/users`
2. GraphQL API
    - Flexible API, you choose what data you want
    - **Example:** `POST /graphql` with a query body
3. SOAP API
    - XML-based (old format, not common in Flutter)
    - **Example:** `POST /Service.asmx`
4. WebSocket API
    - Real-time connection (for chat, notifications)
    - **Example:** `wss://chat.example.com`
- For Flutter apps, REST API is the most common.
## HTTP Methods (types of requests)
- `GET` (Get (read) data from the server):
    - **Example:** `/users`
    - **Real-life Use:** Load user list
- `POST` (Send (create) new data)
    - **Example:** `/register`
    - **Real-life Use:** Create account
- `PUT` Update existing data
    - **Example:** `/users/1`
    - **Real-life Use:** Edit profile
- `PATCH` (Partially update data)
    - **Example:** `/users/1`
    - **Real-life Use:** Update only name
- `DELETE` (Delete data)
    - **Example:** `/users/1`
    - **Real-life Use:** Delete account
## Structure of an API Request
```dart
➡️ Request
---------------------------------------
Method: POST
URL: https://api.example.com/login
Headers:
  Content-Type: application/json
Body:
  {
    "email": "anam@gmail.com",
    "password": "123456"
  }
```
And the server replies:
```dart
⬅️ Response
---------------------------------------
Status: 200 OK
Headers:
  Content-Type: application/json
Body:
  {
    "user_id": 1,
    "name": "Anam",
    "token": "abc123xyz"
  }
```
## Understanding JSON (JavaScript Object Notation)
- JSON is a text-based format used to send data between app and server.
Flutter decodes it into Map<String, dynamic>.
- **Example:**
```dart
{
  "id": 101,
  "name": "Anam",
  "email": "anam@example.com",
  "skills": ["Flutter", "UI Design"],
  "profile": {
    "age": 22,
    "city": "Lahore"
  }
}
```
### JSON Rules
- Data is in key–value pairs
- Keys are always strings
- Values can be:
    - String → "Anam"
    - Number → 101
    - Boolean → true / false
    - Array/List → ["Flutter", "UI"]
    - Object → { "age": 22 }
## Parsing JSON into Models (Recommended in real projects)
```dart
class Todo {
  final int id;
  final String title;
  final bool completed;

  Todo({required this.id, required this.title, required this.completed});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      completed: json['completed'],
    );
  }
}
```
**Then:**
```dart
final data = json.decode(response.body);
final todo = Todo.fromJson(data);
print(todo.title);
```
## Use FutureBuilder to show async data in UI
```dart
Future<Todo> fetchTodo() async {
  final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos/1'));
  if (response.statusCode == 200) {
    return Todo.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load todo');
  }
}
// ----------------------- UI ---------------------------
FutureBuilder<Todo>(
  future: fetchTodo(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return Text('Todo: ${snapshot.data!.title}');
    }
  },
)
```
## Handling Errors and Timeouts
- AsyncValue.guard replaces manual **try/catch** by converting thrown errors to AsyncError(e, stackTrace) automatically.
```dart
try {
  final response = await http
      .get(Uri.parse('https://api.fakeurl.com'),)
      .timeout(const Duration(seconds: 10));

  if (response.statusCode == 200) {
    print('Data: ${response.body}');
  } else {
    print('Server error: ${response.statusCode}');
  }
} on TimeoutException {
  print('⏳ Request timed out');
} catch (e) {
  print('❌ Error: $e');
}
```
## Structure of a Typical API Response
- Status code
    - 200 (OK), 404 (Not Found), 500 (Server Error)
    - **Example:** `response.statusCode`
- Headers
    - Info like type, encoding
    - **Exmaple:** `response.headers['content-type']`
    - **What are HTTP Headers?**
        - Headers are small pieces of information sent alongside every API request or response.
        - They don’t contain the main data (that’s in the body), but they describe how the data should be processed, interpreted, or authorized.
        - Think of them like:
            - `Meta-information` or `Instructions` attached to your API call.
    - **When do we use Headers?**
        - **In requests (sent by your app):** to tell the server who you are, what you’re sending, and what format you expect back.
        - **In responses (sent by server):** to tell your app how to handle the returned data — what type, encoding, or caching rules apply.
    - **Structure of Headers**
        ```dart
        Content-Type: application/json
        Authorization: Bearer abc123
        Accept: application/json
        Cache-Control: no-cache
        ```
    - **Example in Flutter**
        ```dart
        final response = await http.post(
        Uri.parse('https://api.example.com/login'),
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer abc123',
        },
        body: jsonEncode({'email': 'anam@gmail.com', 'password': '123456'}),
        );
        ``` 
        - You’re sending JSON data.
        - You want the server to reply in JSON.
        - You have authorization token to verify your identity.
- Body
    - Actual data (JSON, HTML, etc.)
    - **Example:** `response.body`
```txt
200 ✅ Success
201 ✅ Created
400 ❌ Bad Request
401 🔐 Unauthorized
404 🚫 Not Found
500 💥 Server Error
```





