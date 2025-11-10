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
