import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String text;
  final String category;
  final String createdBy;
  final String authorUsername;
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
    required this.likes,
    required this.dislikes,
    required this.comments,
    required this.createdAt,
  });

  factory Post.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Post(
      id: (data['id'] ?? doc.id) as String,
      text: (data['text'] ?? '') as String,
      category: (data['category'] ?? 'Other') as String,
      createdBy: (data['createdBy'] ?? '') as String,
      authorUsername: (data['authorUsername'] ?? 'unknown') as String,
      likes: (data['likes'] ?? 0) as int,
      dislikes: (data['dislikes'] ?? 0) as int,
      comments: (data['comments'] ?? 0) as int,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}
