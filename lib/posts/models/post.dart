import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String text;
  final String category;
  final String createdBy;
  final String authorUsername;
  final String authorPhotoUrl;
  final double authorPhotoAlignX;
  final double authorPhotoAlignY;
  final int likes;
  final int dislikes;
  final int comments;
  final Timestamp? createdAt;

  const Post({
    required this.id,
    required this.text,
    required this.category,
    required this.createdBy,
    required this.authorUsername,
    required this.authorPhotoUrl,
    required this.authorPhotoAlignX,
    required this.authorPhotoAlignY,
    required this.likes,
    required this.dislikes,
    required this.comments,
    required this.createdAt,
  });

  factory Post.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final alignX = data['authorPhotoAlignX'];
    final alignY = data['authorPhotoAlignY'];
    return Post(
      id: (data['id'] ?? doc.id) as String,
      text: (data['text'] ?? '') as String,
      category: (data['category'] ?? 'Other') as String,
      createdBy: (data['createdBy'] ?? '') as String,
      authorUsername: (data['authorUsername'] ?? 'unknown') as String,
      authorPhotoUrl: (data['authorPhotoUrl'] ?? '') as String,
      authorPhotoAlignX: alignX is num ? alignX.toDouble() : 0.0,
      authorPhotoAlignY: alignY is num ? alignY.toDouble() : 0.0,
      likes: (data['likes'] ?? 0) as int,
      dislikes: (data['dislikes'] ?? 0) as int,
      comments: (data['comments'] ?? 0) as int,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}
