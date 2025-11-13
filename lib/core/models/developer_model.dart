import 'package:cloud_firestore/cloud_firestore.dart';

class Developer {
  final String id;
  final String name;
  final String experienceLevel;
  final String idUser;
  final String idManager;

  Developer({
    required this.id,
    required this.name,
    required this.experienceLevel,
    required this.idUser,
    required this.idManager,
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
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      experienceLevel: map['experienceLevel'] ?? '',
      idUser: map['idUser'] ?? '',
      idManager: map['idManager'] ?? '',
    );
  }
}
