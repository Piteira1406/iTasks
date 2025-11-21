import 'package:cloud_firestore/cloud_firestore.dart';

class TaskTypeModel {
  final int id;
  final String name;

  TaskTypeModel({required this.id, required this.name});

  // Converte um objeto TaskTypeModel num Map para o Firestore
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  // Cria um TaskTypeModel a partir de um documento do Firestore
  factory TaskTypeModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return TaskTypeModel(id: map['id'] ?? 0, name: map['name'] ?? '');
  }

  TaskTypeModel copyWith({int? id, String? name}) {
    return TaskTypeModel(id: id ?? this.id, name: name ?? this.name);
  }
}
