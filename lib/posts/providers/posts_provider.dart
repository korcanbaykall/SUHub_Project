import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/posts_repository.dart';

class PostsProvider extends ChangeNotifier {
  final PostsRepository _repo;

  bool _busy = false;
  String? _error;

  PostsProvider({PostsRepository? repo}) : _repo = repo ?? PostsRepository();

  bool get busy => _busy;
  String? get error => _error;

  Stream<List<Post>> postsStream() => _repo.streamPosts();

  Stream<Post> postStream(String id) => _repo.streamPost(id);

  Stream<String?> reactionStream(String postId, String uid) =>
      _repo.streamReaction(postId, uid);

  Stream<List<Map<String, dynamic>>> streamComments(String postId) =>
      _repo.streamComments(postId);

  Stream<List<Post>> postsByCategoryStream(String category) {
    return _repo.postsByCategoryStream(category);
  }

  Stream<List<Post>> topPostsStream() {
    return _repo.streamTopPosts();
  }

  Future<void> createPost({
    required String text,
    required String category,
    required String createdBy,
    required String authorUsername,
    required String authorPhotoUrl,
    required double authorPhotoAlignX,
    required double authorPhotoAlignY,
  }) async {
    _busy = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.createPost(
        text: text,
        category: category,
        createdBy: createdBy,
        authorUsername: authorUsername,
        authorPhotoUrl: authorPhotoUrl,
        authorPhotoAlignX: authorPhotoAlignX,
        authorPhotoAlignY: authorPhotoAlignY,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> updatePost({
    required String id,
    required String text,
    required String category,
  }) async {
    _busy = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.updatePost(id: id, text: text, category: category);
    } catch (e) {
      _error = e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> deletePost(String id) async {
    _busy = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.deletePost(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
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
    _busy = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.addComment(
        postId: postId,
        text: text,
        createdBy: createdBy,
        authorUsername: authorUsername,
        authorPhotoUrl: authorPhotoUrl,
        authorPhotoAlignX: authorPhotoAlignX,
        authorPhotoAlignY: authorPhotoAlignY,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    _busy = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.deleteComment(postId: postId, commentId: commentId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> toggleReaction({
    required String postId,
    required String uid,
    required String type,
  }) async {
    _busy = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.toggleReaction(postId: postId, uid: uid, type: type);
    } catch (e) {
      _error = e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}

