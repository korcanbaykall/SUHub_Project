import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String text;
  final String createdBy;
  final String authorUsername;
  final Timestamp? createdAt;

  const Comment({
    required this.id,
    required this.text,
    required this.createdBy,
    required this.authorUsername,
    required this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> data) {
    return Comment(
      id: (data['id'] ?? '') as String,
      text: (data['text'] ?? '') as String,
      createdBy: (data['createdBy'] ?? '') as String,
      authorUsername: (data['authorUsername'] ?? 'unknown') as String,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}
