import 'package:cloud_firestore/cloud_firestore.dart';

class Task{
  final String id;
  final String description;
  final String taskStatus;
  final int order;
  final int storyPoints;


  final Timestamp creationDate;
  final Timestamp previsionEndDate;
  final Timestamp previsionStartDate;
  final Timestamp realEndDate;
  final Timestamp realStartDate;

  final String idManager;
  final String idDeveloper;
  final String idTaskType;

  Task({
    required this.id,
    required this.description,
    required this.taskStatus,
    required this.order,
    required this.storyPoints,
    required this.creationDate,
    required this.previsionEndDate,
    required this.previsionStartDate,
    required this.realEndDate,
    required this.realStartDate,
    required this.idManager,
    required this.idDeveloper,
    required this.idTaskType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'taskStatus': taskStatus,
      'order': order,
      'storyPoints': storyPoints,
      'creationDate': creationDate,
      'previsionEndDate': previsionEndDate,
      'previsionStartDate': previsionStartDate,
      'realEndDate': realEndDate,
      'realStartDate': realStartDate,
      'idManager': idManager,
      'idDeveloper': idDeveloper,
      'idTaskType': idTaskType,
    };
  }


  factory Task.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Task(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      taskStatus: map['taskStatus'] ?? '',
      order: map['order'] ?? 0,
      storyPoints: map['storyPoints'] ?? 0,
      creationDate: map['creationDate'] ?? Timestamp.now(),
      previsionEndDate: map['previsionEndDate'] ?? Timestamp.now(),
      previsionStartDate: map['previsionStartDate'] ?? Timestamp.now(),
      realEndDate: map['realEndDate'],
      realStartDate: map['realStartDate'],
      idManager: map['idManager'] ?? '',
      idDeveloper: map['idDeveloper'] ?? '',
      idTaskType: map['idTaskType'] ?? '',
    );
  }

}