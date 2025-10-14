import 'package:cloud_firestore/cloud_firestore.dart';

class Manager {
  final String id;
  final String name;
  final String department;
  final String iduser;

  Manager({
    required this.id,
    required this.name,
    required this.department,
    required this.iduser,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'iduser': iduser,
    };
  }

  factory Manager.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Manager(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      department: map['department'] ?? '',
      iduser: map['iduser'] ?? '',
    );
  }
}