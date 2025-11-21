import 'package:cloud_firestore/cloud_firestore.dart';

class Developer {
  final int id;
  final String name;
  final String experienceLevel;
  final int idUser;
  final int idManager;
  final String? docId; // Document ID do Firestore

  Developer({
    required this.id,
    required this.name,
    required this.experienceLevel,
    required this.idUser,
    required this.idManager,
    this.docId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'experienceLevel': experienceLevel,
      'idUser': idUser,
      'idManager': idManager,
    };
  }

  factory Developer.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Developer(
      id: _parseInt(map['id']),
      name: map['name'] ?? '',
      experienceLevel: map['experienceLevel'] ?? '',
      idUser: _parseInt(map['idUser']),
      idManager: _parseInt(map['idManager']),
      docId: doc.id,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
