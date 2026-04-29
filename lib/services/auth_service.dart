import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Aktuálny prihlásený používateľ
  User? get currentUser => _auth.currentUser;

  // Stream zmien prihlásenia (null = odhlásený)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Prihlásenie cez Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // používateľ zrušil

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e, stackTrace) {
      print('Google Sign-In error: $e');
      print('StackTrace: $stackTrace');
      return null;
    }
  }

  // Odhlásenie
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ID aktuálneho používateľa
  String? get userId => _auth.currentUser?.uid;

  // Meno používateľa
  String? get userName => _auth.currentUser?.displayName;

  // Email používateľa
  String? get userEmail => _auth.currentUser?.email;

  // Foto URL používateľa
  String? get userPhotoUrl => _auth.currentUser?.photoURL;
}