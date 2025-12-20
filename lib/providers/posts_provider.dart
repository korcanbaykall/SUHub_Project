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

  Future<void> createPost({
    required String text,
    required String category,
    required String createdBy,
    required String authorUsername,
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
}

