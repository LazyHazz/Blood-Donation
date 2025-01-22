import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in method
  Future<User?> signIn(String email, String password) async {
    try {
      // Attempt sign in
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuth exceptions
      switch (e.code) {
        case 'user-not-found':
          // ignore: avoid_print
          print('No user found for that email.');
          break;
        case 'wrong-password':
          // ignore: avoid_print
          print('Incorrect password.');
          break;
        default:
          // ignore: avoid_print
          print('Login failed: ${e.message}');
      }
      return null;
    } catch (e) {
      // Catch any other exceptions
      // ignore: avoid_print
      print('Error during sign-in: $e');
      return null;
    }
  }

  // Sign out method
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // ignore: avoid_print
      print('Error during sign out: $e');
    }
  }
}
