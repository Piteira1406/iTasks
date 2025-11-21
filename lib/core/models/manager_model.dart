import 'package:cloud_firestore/cloud_firestore.dart';

class Manager {
  final int id;
  final String name;
  final String department;
  final int idUser;
  final String? docId; // Document ID do Firestore

  Manager({
    required this.id,
    required this.name,
    required this.department,
    required this.idUser,
    this.docId,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'department': department, 'idUser': idUser};
  }

  factory Manager.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Manager(
      id: _parseInt(map['id']),
      name: map['name'] ?? '',
      department: map['department'] ?? '',
      idUser: _parseInt(map['idUser']),
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
