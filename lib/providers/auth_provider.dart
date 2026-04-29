import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get userId => _user?.uid;

  AuthProvider() {
    // Sleduj zmeny prihlásenia automaticky
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    final user = await _authService.signInWithGoogle();

    _isLoading = false;
    notifyListeners();

    return user != null;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}