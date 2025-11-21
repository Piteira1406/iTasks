import 'package:cloud_firestore/cloud_firestore.dart';

class TaskTypeModel {
  final int id;
  final String name;
  final String? docId; // Document ID do Firestore (pode ser diferente do campo 'id')

  TaskTypeModel({
    required this.id,
    required this.name,
    this.docId,
  });

  // Converte um objeto TaskTypeModel num Map para o Firestore
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  // Cria um TaskTypeModel a partir de um documento do Firestore
  factory TaskTypeModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return TaskTypeModel(
      id: _parseInt(map['id']),
      name: map['name'] ?? '',
      docId: doc.id, // Guarda o document ID real
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  TaskTypeModel copyWith({int? id, String? name, String? docId}) {
    return TaskTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      docId: docId ?? this.docId,
    );
  }
}
