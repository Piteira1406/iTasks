import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  final String id;
  final String name;
  final String username;
  final String type;
  final String email;


User({
  required this.id,
  required this.name,
  required this.username,
  required this.type,
  required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'type': type,
      'email': email,
    };
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      type: map['type'] ?? '',
      email: map['email'] ?? '',
    );
  }
}