// lib/core/models/task_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// 1. A classe chama-se 'Task', como pediu
class Task {
  final String id;
  final String description;
  final String taskStatus;
  final int order;
  final int storyPoints;

  final DateTime creationDate;
  final DateTime previsionEndDate;
  final DateTime previsionStartDate;

  // 2. Corrigido: Datas reais PODEM ser nulas (usando '?')
  final DateTime? realEndDate;
  final DateTime? realStartDate;

  final int idManager;
  final int idDeveloper;
  final int idTaskType;

  Task({
    required this.id,
    required this.description,
    required this.taskStatus,
    required this.order,
    required this.storyPoints,
    required this.creationDate,
    required this.previsionEndDate,
    required this.previsionStartDate,
    this.realEndDate, // 3. Corrigido: Removido 'required'
    this.realStartDate, // 3. Corrigido: Removido 'required'
    required this.idManager,
    required this.idDeveloper,
    required this.idTaskType,
  });

  // 4. Corrigido 'fromFirestore' para lidar com Timestamps e IDs
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;

    return Task(
      id: doc.id, // O ID vem do documento, não do 'map'
      description: map['description'] ?? '',
      taskStatus: map['taskStatus'] ?? 'ToDo', // Default para ToDo
      order: _toInt(map['order']),
      storyPoints: _toInt(map['storyPoints']),

      // Converte Timestamps para DateTimes
      creationDate: timestampToDateTime(map['creationDate']) ?? DateTime.now(),
      previsionEndDate:
          timestampToDateTime(map['previsionEndDate']) ?? DateTime.now(),
      previsionStartDate:
          timestampToDateTime(map['previsionStartDate']) ?? DateTime.now(),

      // Datas reais são nulas se não existirem
      realEndDate: timestampToDateTime(map['realEndDate']),
      realStartDate: timestampToDateTime(map['realStartDate']),

      idManager: _toInt(map['idManager']),
      idDeveloper: _toInt(map['idDeveloper']),
      idTaskType: _toInt(map['idTaskType']),
    );
  }

  // 5. Método 'toMap' para salvar no Firestore (converte DateTime para Timestamp)
  Map<String, dynamic> toMap() {
    return {
      // Não incluímos o 'id', pois é o nome do documento
      'description': description,
      'taskStatus': taskStatus,
      'order': order,
      'storyPoints': storyPoints,
      'creationDate': Timestamp.fromDate(creationDate),
      'previsionEndDate': Timestamp.fromDate(previsionEndDate),
      'previsionStartDate': Timestamp.fromDate(previsionStartDate),
      'realEndDate': realEndDate != null
          ? Timestamp.fromDate(realEndDate!)
          : null,
      'realStartDate': realStartDate != null
          ? Timestamp.fromDate(realStartDate!)
          : null,
      'idManager': idManager,
      'idDeveloper': idDeveloper,
      'idTaskType': idTaskType,
    };
  }

  // 6. Método 'copyWith' (necessário para o provider)
  Task copyWith({
    String? id,
    String? description,
    String? taskStatus,
    int? order,
    int? storyPoints,
    DateTime? creationDate,
    DateTime? previsionEndDate,
    DateTime? previsionStartDate,
    DateTime? realEndDate,
    DateTime? realStartDate,
    int? idManager,
    int? idDeveloper,
    int? idTaskType,
  }) {
    return Task(
      id: id ?? this.id,
      description: description ?? this.description,
      taskStatus: taskStatus ?? this.taskStatus,
      order: order ?? this.order,
      storyPoints: storyPoints ?? this.storyPoints,
      creationDate: creationDate ?? this.creationDate,
      previsionEndDate: previsionEndDate ?? this.previsionEndDate,
      previsionStartDate: previsionStartDate ?? this.previsionStartDate,
      realEndDate: realEndDate ?? this.realEndDate,
      realStartDate: realStartDate ?? this.realStartDate,
      idManager: idManager ?? this.idManager,
      idDeveloper: idDeveloper ?? this.idDeveloper,
      idTaskType: idTaskType ?? this.idTaskType,
    );
  }

  /// Safe conversion from dynamic to int
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }
}
