import "package:firebase_auth/firebase_auth.dart";

class Authentication{
  final FirebaseAuth _fireBaseAuth = FirebaseAuth.instance;
  User? get currentUser => _fireBaseAuth.currentUser;

  Stream<User ?> get authStateChanges => _fireBaseAuth.authStateChanges();

  Future<void> signInwithEmailAndPass({
    required String email,
    required String password,
  }) async{
    await _fireBaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createUserWithEmailAndPass({
    required String email,
    required String password,
  }) async{
    await _fireBaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async{
    await _fireBaseAuth.signOut();
  }
}

