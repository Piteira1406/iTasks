import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  //Auth methods like signIn, signOut, register can be added here. WARNING: REGISTER DONT CREATE FIRESTORE USER DOCUMENT!! ONLY AUTH USER.

  Future<UserCredential?> signInWithEmail({required String email, required String password}) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);

    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserCredential?> createUserInAuth({
      required String email,
      required String password
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }


}