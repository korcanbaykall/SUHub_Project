import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../profile/models/user_profile.dart';
import '../services/auth_service.dart';
import '../../profile/services/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserRepository _userRepo;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get user => _auth.currentUser;
  User? _user;
  UserProfile? _profile;

  bool _isLoading = false;
  bool _isInitializing = true;
  String? _error;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<UserProfile>? _profileSub;

  AuthProvider({
    AuthService? authService,
    UserRepository? userRepo,
  })  : _authService = authService ?? AuthService(),
        _userRepo = userRepo ?? UserRepository() {
    _user = _authService.currentUser;

    _authSub = _authService.authStateChanges.listen((u) {
      _user = u;
      _profile = null;
      _profileSub?.cancel();

      if (u != null) {
        _profileSub = _userRepo.streamProfile(u.uid).listen((p) {
          _profile = p;
          notifyListeners();
        });
      }

      _isInitializing = false;
      notifyListeners();
    });
  }

  UserProfile? get profile => _profile;

  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get error => _error;

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  String _friendlyAuthError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'Invalid e-mail';
        case 'user-not-found':
          return 'User not found';
        case 'wrong-password':
          return 'Wrong Password';
        case 'email-already-in-use':
          return 'E-mail already exists';
        case 'weak-password':
          return 'Weak Password (at least 6 characters).';
        case 'network-request-failed':
          return 'Weak network connection, try again.';
        default:
          return e.message ?? 'An unexpected error occurred.';
      }
    }
    return 'An unexpected error occurred.';
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    _isLoading = true;
    _setError(null);

    try {
      await _authService.signUp(
        email: email,
        password: password,
        username: username,
      );
      return true;
    } catch (e) {
      _setError(_friendlyAuthError(e));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _setError(null);

    try {
      await _authService.signIn(email: email, password: password);
      return true;
    } catch (e) {
      _setError(_friendlyAuthError(e));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
  Future<void> updateUsername(String newUsername) async {
    if (_user == null) return;

    _isLoading = true;
    _setError(null);
    notifyListeners();

    try {
      await _userRepo.updateUsername(_user!.uid, newUsername);
    } catch (e) {
      _setError('Username is not updated.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_user == null || _user!.email == null) {
      _setError('User not found');
      return;
    }

    _isLoading = true;
    _setError(null);
    notifyListeners();

    try {
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: oldPassword,
      );

      await _user!.reauthenticateWithCredential(credential);
      await _user!.updatePassword(newPassword);
    } catch (e) {
      _setError(_friendlyAuthError(e));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}

