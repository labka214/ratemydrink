import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'drinks_provider.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  DrinksProvider? _drinksProvider;

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

  // Vlož DrinksProvider, aby po prihlásení mohol "zahriať" dáta ešte
  // pred navigáciou na hlavnú obrazovku (viď main.dart).
  void attachDrinksProvider(DrinksProvider drinksProvider) {
    _drinksProvider = drinksProvider;
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    final user = await _authService.signInWithGoogle();

    if (user != null) {
      await _drinksProvider?.loadFavoritesOnce(user.uid);
    }

    _isLoading = false;
    notifyListeners();

    return user != null;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}