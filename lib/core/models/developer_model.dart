import 'package:cloud_firestore/cloud_firestore.dart';

class Developer {
  final int id;
  final String name;
  final String experienceLevel;
  final int idUser;
  final int idManager;

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
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      experienceLevel: map['experienceLevel'] ?? '',
      idUser: map['idUser'] ?? 0,
      idManager: map['idManager'] ?? 0,
    );
  }
}
