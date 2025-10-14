import 'package:cloud_firestore/cloud_firestore.dart';

class user{
  final String id;
  final String name;
  final String username;
  final String type;
  final String password;


user({
  required this.id,
  required this.name,
  required this.username,
  required this.type,
  required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'type': type,
      'password': password,
    };
  }

  factory user.FromFirestore(DocumentSnapshot doc){
    final map = doc.data() as Map<String, dynamic>;
    return user(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      type: map['type'] ?? '',
      password: map['password'] ?? '',
    );
  }
}