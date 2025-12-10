import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
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
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Utilizador criado: ${credential.user?.email}');
      return credential;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('❌ Erro genérico: $e');
      return null;
    }
  }

  Future<String?> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Não existe nenhuma conta com este email.';
        case 'invalid-email':
          return 'Email inválido.';
        default:
          return 'Erro ao enviar email: ${e.message}';
      }
    } catch (e) {
      return 'Erro ao enviar email: ${e.toString()}';
    }
  }
}