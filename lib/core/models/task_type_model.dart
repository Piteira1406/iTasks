// lib/core/models/task_type_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class TaskTypeModel {
  final String id;
  final String name;

  TaskTypeModel({required this.id, required this.name});

  // Converte um objeto TaskTypeModel num Map para o Firestore
  Map<String, dynamic> toMap() {
    return {
      // O ID não é incluído no map, pois é o ID do documento
      'name': name,
    };
  }

  // Cria um TaskTypeModel a partir de um documento do Firestore
  factory TaskTypeModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return TaskTypeModel(
      id: doc.id, // Pega o ID do documento
      name: map['name'] ?? '',
    );
  }

  // --- MÉTODO 'copyWith' ADICIONADO ---
  // (Corrige o erro 'copyWith isn't defined')
  // Cria uma *cópia* do objeto, mas permite alterar alguns campos
  TaskTypeModel copyWith({String? id, String? name}) {
    return TaskTypeModel(id: id ?? this.id, name: name ?? this.name);
  }
}
