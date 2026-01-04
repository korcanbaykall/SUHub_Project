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

  Stream<List<Post>> streamTopPosts() {
    return _db
        .collection('posts')
        .snapshots()
        .map((snap) {
      final posts =
      snap.docs.map((d) => Post.fromDoc(d)).toList();

      posts.sort((a, b) {
        final scoreA = a.likes + a.comments;
        final scoreB = b.likes + b.comments;
        return scoreB.compareTo(scoreA);
      });

      return posts;
    });
  }

  Stream<Post> streamPost(String id) {
    return _db.collection('posts').doc(id).snapshots().map((doc) => Post.fromDoc(doc));
  }

  Stream<String?> streamReaction(String postId, String uid) {
    return _db
        .collection('posts')
        .doc(postId)
        .collection('reactions')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data()?['type'] as String?);
  }

  Stream<List<Map<String, dynamic>>> streamComments(String postId) {
    return _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Stream<List<Post>> postsByCategoryStream(String category) {
    return streamPosts().map(
          (posts) =>
          posts.where((p) => p.category == category).toList(),
    );
  }


  Future<void> createPost({
    required String text,
    required String category,
    required String createdBy,
    required String authorUsername,
    required String authorPhotoUrl,
    required double authorPhotoAlignX,
    required double authorPhotoAlignY,
    String? imageUrl,
  }) async {
    final doc = _db.collection('posts').doc();
    await doc.set({
      'id': doc.id,
      'text': text,
      'category': category,
      'createdBy': createdBy,
      'authorUsername': authorUsername,
      'authorPhotoUrl': authorPhotoUrl,
      'authorPhotoAlignX': authorPhotoAlignX,
      'authorPhotoAlignY': authorPhotoAlignY,
      'imageUrl': imageUrl ?? '',
      'likes': 0,
      'dislikes': 0,
      'comments': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addComment({
    required String postId,
    required String text,
    required String createdBy,
    required String authorUsername,
    required String authorPhotoUrl,
    required double authorPhotoAlignX,
    required double authorPhotoAlignY,
  }) async {
    final postRef = _db.collection('posts').doc(postId);
    final commentRef = postRef.collection('comments').doc();

    await _db.runTransaction((tx) async {
      tx.set(commentRef, {
        'id': commentRef.id,
        'text': text,
        'createdBy': createdBy,
        'authorUsername': authorUsername,
        'authorPhotoUrl': authorPhotoUrl,
        'authorPhotoAlignX': authorPhotoAlignX,
        'authorPhotoAlignY': authorPhotoAlignY,
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.update(postRef, {'comments': FieldValue.increment(1)});
    });
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final postRef = _db.collection('posts').doc(postId);
    final commentRef = postRef.collection('comments').doc(commentId);

    await _db.runTransaction((tx) async {
      tx.delete(commentRef);
      tx.update(postRef, {'comments': FieldValue.increment(-1)});
    });
  }

  Future<void> toggleReaction({
    required String postId,
    required String uid,
    required String type, // like | dislike
  }) async {
    final postRef = _db.collection('posts').doc(postId);
    final reactionRef = postRef.collection('reactions').doc(uid);

    await _db.runTransaction((tx) async {
      final reactionSnap = await tx.get(reactionRef);
      final data = reactionSnap.data();
      final current = data == null ? null : data['type'] as String?;

      if (current == type) {
        tx.delete(reactionRef);
        tx.update(postRef, {
          type == 'like' ? 'likes' : 'dislikes': FieldValue.increment(-1),
        });
        return;
      }

      if (current == null) {
        tx.set(reactionRef, {'type': type});
        tx.update(postRef, {
          type == 'like' ? 'likes' : 'dislikes': FieldValue.increment(1),
        });
        return;
      }

      tx.set(reactionRef, {'type': type});
      tx.update(postRef, {
        current == 'like' ? 'likes' : 'dislikes': FieldValue.increment(-1),
        type == 'like' ? 'likes' : 'dislikes': FieldValue.increment(1),
      });
    });
  }

  Future<void> updatePost({
    required String id,
    required String text,
    required String category,
    String? imageUrl,
  }) async {
    final update = {
      'text': text,
      'category': category,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (imageUrl != null) {
      update['imageUrl'] = imageUrl;
    }
    await _db.collection('posts').doc(id).update(update);
  }

  Future<void> deletePost(String id) async {
    await _db.collection('posts').doc(id).delete();
  }
}
