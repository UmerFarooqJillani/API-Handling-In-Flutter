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
## Professional: Dio + json_serializable (or Freezed) + typed exceptions + repository interface



