import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String text;
  final String createdBy;
  final String authorUsername;
  final String authorPhotoUrl;
  final double authorPhotoAlignX;
  final double authorPhotoAlignY;
  final Timestamp? createdAt;

  const Comment({
    required this.id,
    required this.text,
    required this.createdBy,
    required this.authorUsername,
    required this.authorPhotoUrl,
    required this.authorPhotoAlignX,
    required this.authorPhotoAlignY,
    required this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> data) {
    final alignX = data['authorPhotoAlignX'];
    final alignY = data['authorPhotoAlignY'];
    return Comment(
      id: (data['id'] ?? '') as String,
      text: (data['text'] ?? '') as String,
      createdBy: (data['createdBy'] ?? '') as String,
      authorUsername: (data['authorUsername'] ?? 'unknown') as String,
      authorPhotoUrl: (data['authorPhotoUrl'] ?? '') as String,
      authorPhotoAlignX: alignX is num ? alignX.toDouble() : 0.0,
      authorPhotoAlignY: alignY is num ? alignY.toDouble() : 0.0,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}
