import 'package:cloud_firestore/cloud_firestore.dart';

class typetask{
  final String id;
  final String name;

  typetask({
    required this.id,
    required this.name,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory typetask.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return typetask(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
    );
  }
}