import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final int id;
  final String uid; // Firebase Auth UID (document ID)
  final String name;
  final String username;
  final String type;
  final String email;

  AppUser({
    required this.id,
    required this.uid,
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
      // uid não vai no map pois é o ID do documento
    };
  }

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: _parseInt(map['id']),
      uid: doc.id, // Pegar o UID do documento
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      type: map['type'] ?? '',
      email: map['email'] ?? '',
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
