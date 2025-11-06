# <p align="center"> basic_of_rest_api </p>

## What is a REST API?
- REST API (Representational State Transfer API) is a set of rules that define how two systems (your Flutter app and a server) can talk to each other using HTTP.
- It uses URLs + HTTP Methods (GET, POST, PUT, DELETE) to perform operations on resources like users, posts, products, etc.<br>
**Example:**
    ```dart
    GET https://api.example.com/users      → Get all users
    GET https://api.example.com/users/1    → Get one user
    POST https://api.example.com/users     → Add new user
    PUT https://api.example.com/users/1    → Update user 1
    DELETE https://api.example.com/users/1 → Delete user 1
    ```
## REST API = Client + Server Architecture
- **Client (Frontend)**	Your Flutter app (sends requests)
- **Server (Backend)** The API hosted on a web server (responds)
- **Database** Where real data is stored (MySQL, MongoDB, etc.)
- Communication Flow:
    1. User performs action → Flutter app sends an HTTP request.
    2. Server processes the request.
    3. Server sends a response (usually in JSON).
    4. Flutter displays the data.
## REST API URL Structure<br>
**https** Protocol (secure web request)<br>
**api.example.com**	Domain (server host)<br>
**/users** Resource (what data you want)<br>
**/1** Specific resource ID<br>
**Example:**
```dart
https://api.example.com/users/1
```
## REST API vs GraphQL vs SOAP
- Data format	
    - REST & GraphQL	
        - JSON	
    - SOAP
        - XML
- Request type
    - REST
        - Multiple endpoints	
	- GraphQL
        - Single endpoint with queries	
	- SOAP
        - Single
- Flexibility
    - REST
        - Fixed response
    - GraphQL
        - Client defines data	
    - SOAP
        - Rigid
- Common in Flutter?	
	- REST
        - Yes	
    - GraphQL
        - Sometimes
    - SOAP
        - Rare
## REST API Integration Flow in Flutter
1. Create a model (representing JSON)
2. Create a service/repository (calls API)
3. Manage state with Riverpod / FutureProvider
4. Show results in UI
## REST API Security (Important)
- APIs must be secure, especially when dealing with user info.
- Technique:
    - Bearer Token
        - **Header:** Authorization (Bearer xyz123)
    - API Key
        - **Header:** x-api-key (x-api-key: abcd1234)
    - OAuth2
        - **Header:** Access + Refresh tokens (Google login)
    - HTTPS
        - **Header:** Encrypted connection (https://)
## Beginner: Quick REST service + manual JSON parsing <br>
**Example API response (GET /stories):**
```dart
[
  {
    "id": "1",
    "title": "The Clever Fox",
    "body": "Once upon a time..."
  },
  {
    "id": "2",
    "title": "The Brave Mouse",
    "body": "A little mouse..."
  }
]
```
**Manual model (simple):**
```dart
// lib/features/stories/data/models/story_dto.dart
class StoryDto {
  final String id;
  final String title;
  final String body;

  StoryDto({required this.id, required this.title, required this.body});

  factory StoryDto.fromJson(Map<String, dynamic> json) {
    return StoryDto(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
  };
}
```
**Repository (using http package):**
```dart
// lib/features/stories/data/story_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/story_dto.dart';

class StoryRepository {
  final String baseUrl;
  StoryRepository({required this.baseUrl});

  Future<List<StoryDto>> fetchStories({int page = 1}) async {
    final uri = Uri.parse('$baseUrl/stories?page=$page');
    final res = await http.get(uri, headers: {'Accept': 'application/json'});

    if (res.statusCode == 200) {
      final List body = json.decode(res.body);
      return body.map((e) => StoryDto.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load stories. Status: ${res.statusCode}');
    }
  }
}
```
**Use with Riverpod (simple FutureProvider):**
```dart
final storyRepoProvider = Provider((ref) => StoryRepository(baseUrl: 'https://api.example.com'));

final storiesProvider = FutureProvider<List<StoryDto>>((ref) {
  final repo = ref.watch(storyRepoProvider);
  return repo.fetchStories();
});
```
## DIO (Deep Explanation)
- Dio is an advanced HTTP client for Flutter/Dart, it’s like http package but with superpowers.
- You use it to make requests to REST APIs (like GET, POST, PUT, DELETE) — but it also lets you:
  - Add headers
  - Use interceptors
  - Handle errors clearly 
  - Use base URLs
  - Automatically serialize/deserialize data
### What is an HTTP client?
- Whenever your app talks to a server (like fetching user data from `https://api.example.com/users`), you need something that can send HTTP requests and receive HTTP responses.
- **Dio is that tool.**
### Why `Dio` instead of `http`?
- `http` is simple (good for learning).
  - ❌ No Interceptors
  - Limited Timeout
  - ❌ No Global base URL
  - ❌ No Retry policy
  - ❌ No Upload/download progress
  - ❌ No Request cancellation
- `dio` is professional-grade (used in large apps, APIs, admin panels, mobile dashboards, etc.)
  - ✅ Yes Interceptors
  - ✅ Flexible Timeout
  - ✅ Built-in Global base URL
  - ✅ Easy via Interceptors Retry policy
  - ✅ Built-in Upload/download progress
  - ✅ Built-in Request cancellation
### Create a Dio client (the `HTTP machine`)
```dart
import 'package:dio/dio.dart';

Dio createDio({required String baseUrl}) {
  final dio = Dio(
    BaseOptions(
      // baseUrl: 'https://api.example.com',
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
      followRedirects: true,
      validateStatus: (code) => code != null && code >= 200 && code < 400,
      // headers: {'Accept': 'application/json'},
      headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      },
    ),
  );
  return dio;
}
```
- `baseUrl:` A prefix added to every request path.
  - If you call dio.get('/users'), real URL becomes `https://api.example.com/users`.
- `connectTimeout:` Max time to connect to the server. If the device can’t reach the server in 8s, it throws a timeout error.
- `receiveTimeout:` Max time to download the response. If server is too slow, this fails.
- `sendTimeout:` Max time to upload your data (like files) before failing.
- `responseType: ResponseType.json`: Tells Dio to expect JSON and parse it for you.
- `followRedirects: true`: If server says “go to another URL,” Dio will follow (e.g., HTTP 302).
- `validateStatus:` A function to decide which HTTP codes are treated as **success.**
  - Here, we accept 200–399 as success. 4xx/5xx are considered **errors.**
- `headers:` Default headers sent with every request (e.g., tokens, content type).
### Why we set these:
- Timeouts prevent your app from `hanging` forever.
- A single baseUrl keeps your code short.
- validateStatus makes it easy to treat 4xx/5xx as errors automatically.
### When to change:
- If your API is slow → increase timeouts.
- If API returns non-JSON (files) → change responseType to bytes/stream.
### Sending Requests
```dart
final response = await dio.get('/users');
print(response.data);
```
**You can also send:**
```dart
await dio.post('/login', data: {'email': 'a@b.com', 'password': '1234'});
await dio.put('/users/1', data: {'name': 'Ali'});
await dio.delete('/users/1');
```
**Each of these returns a Response object containing:**
```dart
response.data   // The JSON or text data from the API
response.statusCode   // HTTP status (e.g., 200, 404)
response.headers   // Response headers
```
### Headers (Deep Explanation)
- Headers are like `metadata` attached to your request, extra information you send to the server.
```dart
Authorization: Bearer <token> ->  For authentication
Content-Type: application/json  ->  Says you’re sending JSON
Accept: application/json  ->  Says you expect JSON back
```
**You can pass headers in two ways:**<br>
- Headers are super important when dealing with secure APIs (like requiring login tokens).
1. Globally (for all requests)
```dart
dio.options.headers['Authorization'] = 'Bearer myToken';
```
2. Per-request
```dart
await dio.get(
  '/users',
  options: Options(headers: {'Authorization': 'Bearer myToken'}),
);
```
### Common mistakes:
- Forgetting baseUrl → you pass full URLs everywhere.
- Very small timeouts → users on slow networks see errors too often.
### Making requests (GET / POST / PUT / DELETE) Code
```dart
final dio = createDio(baseUrl: 'https://api.example.com');

// GET with query parameters (?page=1)
final response = await dio.get('/stories', queryParameters: {'page': 1});

// POST JSON body
final created = await dio.post('/stories', data: {
  'title': 'Hello',
  'body': 'World',
});

// Request with custom headers (only this call)
await dio.get('/me', options: Options(headers: {'X-Feature': 'beta'}));

// -------- Accessing response -----------------------
final code = response.statusCode; // 200, 201, ...
final body = response.data;       // already decoded if JSON
```
- `queryParameters:` turns into `?key=value` in the URL.
- `data:` the JSON body you send in POST/PUT/PATCH.
- `options.headers:` extra headers just for this one request.
### Handling errors (DioException)
- Different errors need different messages and actions (e.g., “check internet,” “retry,” “login again”).
- Common mistake: 
  - Catching only Exception and not checking e.type → you don’t know what failed. 
```dart
try {
  await dio.get('/slow-endpoint');
} on DioException catch (e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:   // connect took too long
    case DioExceptionType.receiveTimeout:      // download too slow
    case DioExceptionType.sendTimeout:         // upload too slow
      // show "Timed out"
      break;
    case DioExceptionType.badResponse:         // server returned 4xx/5xx
      final status = e.response?.statusCode;   // e.g., 401, 404, 500
      break;
    case DioExceptionType.connectionError:     // no internet / socket error
      break;
    case DioExceptionType.cancel:              // you cancelled the request
      break;
    default:                                   // unknown
  }
}
```
## Interceptors (The `Middleware` of Networking)
- Think of interceptors as “checkpoints” in Dio’s pipeline:
  - Before a request is sent (you can modify it)
  - After a response is received (you can process or log it)
  - When an error occurs (you can retry or handle gracefully)
```dart
dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) {
      print('➡️ Sending request: ${options.method} ${options.path}');
      options.headers['Authorization'] = 'Bearer token_here';
      return handler.next(options);
    },
    onResponse: (response, handler) {
      print('✅ Got response: ${response.statusCode}');
      return handler.next(response);
    },
    onError: (error, handler) {
      print('❌ Error: ${error.message}');
      return handler.next(error);
    },
  ),
);
```
## Why it’s powerful: 
- When you build an app, you make many API calls login, get user, fetch posts, etc.
Each call might need:
  - The same headers (like an auth token)
  - Logging (to print requests/responses for debugging)
  - Error handling (like checking for 401 Unauthorized)
- If you handle these things inside every API call, you’ll repeat the same code 10+ times.
- **Interceptors fix** this problem by letting you handle those things once in one place.
Then, Dio automatically applies it to every request.<br>
**Without interceptors:**
- Here you repeat the token logic and error handling everywhere.
```dart
final dio = Dio();

Future<Response> getUser() async {
  final token = await getTokenFromStorage();
  return dio.get(
    'https://api.example.com/user',
    options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ),
  );
}

Future<Response> getPosts() async {
  final token = await getTokenFromStorage();
  return dio.get(
    'https://api.example.com/posts',
    options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ),
  );
}
```
**With interceptors:**
```dart
final dio = Dio();

// Add interceptor once
dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await getTokenFromStorage();
      options.headers['Authorization'] = 'Bearer $token';
      print('➡️ Sending request: ${options.uri}');
      return handler.next(options);
    },
    onResponse: (response, handler) {
      print('✅ Response: ${response.statusCode}');
      return handler.next(response);
    },
    onError: (error, handler) {
      print('❌ Error: ${error.response?.statusCode}');
      if (error.response?.statusCode == 401) {
        // handle unauthorized (maybe refresh token)
      }
      return handler.next(error);
    },
  ),
);
```
### Now every API request automatically:
- You don’t need to repeat that code in every API function. That’s what `centralizing all network logic` means.
  - Adds the token
  - Logs the request/response
  - Handles errors globally