import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class PostsRepository {
  final FirebaseFirestore _db;
  PostsRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  Stream<List<Post>> streamPosts() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Post.fromDoc(d)).toList());
  }

  Stream<Post> streamPost(String id) {
    return _db.collection('posts').doc(id).snapshots().map((doc) => Post.fromDoc(doc));
  }

  Future<void> createPost({
    required String text,
    required String category,
    required String createdBy,
    required String authorUsername,
  }) async {
    final doc = _db.collection('posts').doc();
    await doc.set({
      'id': doc.id,
      'text': text,
      'category': category,
      'createdBy': createdBy,
      'authorUsername': authorUsername,
      'likes': 0,
      'dislikes': 0,
      'comments': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePost({
    required String id,
    required String text,
    required String category,
  }) async {
    await _db.collection('posts').doc(id).update({
      'text': text,
      'category': category,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePost(String id) async {
    await _db.collection('posts').doc(id).delete();
  }
}
