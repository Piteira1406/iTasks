import 'package:cloud_firestore/cloud_firestore.dart';

class TaskType{
  final String id;
  final String name;

  TaskType({
    required this.id,
    required this.name,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory TaskType.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return TaskType(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
    );
  }
}