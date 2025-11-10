# <p align="center"> handling_json </p>

- When you fetch data from an API, the response is usually JSON.
- You must convert JSON → Dart object (for reading) and Dart object → JSON (for sending data back).
- Instead of writing all that manual conversion code, these three packages do it automatically and safely.

## The Three Packages (What, Why, and When)
- `json_annotation` (dependency)
    - Provides annotations like `@JsonSerializable()` and `@JsonKey()`
    - Always needed in your models
- `json_serializable` (dev_dependency)
    - Generates the actual serialization logic (`fromJson`, `toJson`)
    - Needed when generating code
- `build_runner` (dev_dependency)
    - Runs code generation commands (builds `.g.dart` files)
    - Run this every time you change model classes
## Serialization vs Deserialization
- `Serialization` in Flutter, like in other programming environments, is the process of converting an object's state into a format that can be easily stored or transmitted. 
- `Deserialization` is the reverse process, converting the stored or transmitted data back into an object. 
## Manual Conversion with `dart:convert`
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  // Convert JSON -> Dart
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['first_name'],
      email: json['email'],
    );
  }

  // Convert Dart -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': name,
      'email': email,
    };
  }
}

class UserService {
  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('https://reqres.in/api/users'));
    final body = jsonDecode(response.body); // 👈 decode using dart:convert
    final List data = body['data'];

    return data.map((json) => User.fromJson(json)).toList();
  }
}
```
### Pros:
- Simple, no extra dependencies.
- Perfect for small projects or quick tests.
### Cons:
- You must manually write the fromJson() and toJson() functions for every model.
- If your API changes, you must manually update every place.
- Easy to make typos (json['firstName'] vs json['first_name']).
- No type-safety or compile-time checking.
- Can become messy in large apps.
## Automated Conversion with `json_serializable` (Convert `JSON` into `Dart` models automatically)
- When your app grows, and you have many models (User, Post, Product, etc.), it’s tiring to manually write and update conversion code.
- `json_serializable:` It automatically generates the `fromJson()` and `toJson()` methods for you.
### Example with `json_serializable`
```dart
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart'; // Generated automatically

@JsonSerializable()
class User {
  final int id;
  final String firstName;
  final String email;

  User({
    required this.id,
    required this.firstName,
    required this.email,
  });

  // Generated methods
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```
**Then Run:**
```dart
flutter pub run build_runner build
```
**And it will create a file `user_model.g.dart` automatically:**
```dart
User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'email': instance.email,
    };
```
### Pros:
- No need to manually write conversion logic.
- Auto-generated, less error-prone.
- Works great in large projects and clean architecture (data layer).
- Supports nested models, nullable fields, custom keys, etc.
- Fully type-safe and future-proof.
### Cons:
- Setup requires 3 extra packages:
  - json_annotation
  - json_serializable
  - build_runner
- Must run `flutter pub run build_runner` build after changes.
## Pro Tip: How They Work Together (`json_serializable` & `dart:convert`)
- Even json_serializable uses dart:convert under the hood, it just automates the boilerplate code for you.
  ```dart
  User.fromJson(jsonDecode(response.body));
  ```
- `dart:convert` is always used, `json_serializable` just saves you from writing repetitive conversion functions.
## How we used
**Step 1:**
```yaml
dependencies:
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.4.8
  json_serializable: ^6.8.0
```
**Step 2:** Create a Model File<br>
**Example:** `user_model.dart`
```dart
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart'; // 👈 This will be generated automatically

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  /// 🔄 From JSON → Dart object
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// 🔁 From Dart object → JSON
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```
**Step 3:** Generate the Code
```bash
flutter pub run build_runner build
```
**It will automatically create a file called:**
```dart
// file: user_model.g.dart

// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'user_model.dart';

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
    };
```
**Step 4:** Use It in Your Code
```dart
import 'package:dio/dio.dart';
import 'user_model.dart';

class UserService {
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://reqres.in/api'));

  Future<List<User>> fetchUsers() async {
    final response = await dio.get('/users');
    final List data = response.data['data'];

    // Convert JSON → Dart models
    return data.map((json) => User.fromJson(json)).toList();
  }
}
```
**Now, in your UI:**
```dart
final users = await UserService().fetchUsers();
print(users.first.name);  // Prints Ali or whatever name comes from API
```
## Posting Data to Server
```dart
final newUser = User(id: 2, name: 'Fatima', email: 'fatima@example.com');

await dio.post(
  '/users',
  data: newUser.toJson(),  // Dart → JSON
);
```
**When API responds with data:**
```dart
final user = User.fromJson(response.data); // JSON → Dart
```
## Nested Models Example
```json
{
  "id": 1,
  "name": "Ali",
  "address": {
    "city": "Karachi",
    "country": "Pakistan"
  }
}
```
**Dart models:**
```dart
@JsonSerializable()
class Address {
  final String city;
  final String country;

  Address({required this.city, required this.country});
  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);
}

@JsonSerializable()
class User {
  final int id;
  final String name;
  final Address address;

  User({required this.id, required this.name, required this.address});
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```
**Run again:**
```bash
flutter pub run build_runner build
```


