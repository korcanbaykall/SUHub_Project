import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserRepository _userRepo;

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

  User? get user => _user;
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
          return 'Geçersiz e-posta formatı.';
        case 'user-not-found':
          return 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';
        case 'wrong-password':
          return 'Şifre yanlış.';
        case 'email-already-in-use':
          return 'Bu e-posta zaten kullanımda.';
        case 'weak-password':
          return 'Şifre çok zayıf (en az 6 karakter önerilir).';
        case 'network-request-failed':
          return 'İnternet bağlantısı hatası. Tekrar dene.';
        default:
          return e.message ?? 'Giriş/Kayıt sırasında hata oluştu.';
      }
    }
    return 'Beklenmeyen hata oluştu.';
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

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}

