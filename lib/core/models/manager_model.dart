import 'package:cloud_firestore/cloud_firestore.dart';

class Manager {
  final String id;
  final String name;
  final String department;
  final String idUser;

  Manager({
    required this.id,
    required this.name,
    required this.department,
    required this.idUser,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'department': department, 'idUser': idUser};
  }

  factory Manager.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Manager(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      department: map['department'] ?? '',
      idUser: map['idUser'] ?? '',
    );
  }
}
