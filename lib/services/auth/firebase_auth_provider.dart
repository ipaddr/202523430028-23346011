// lib/services/auth/firebase_auth_provider.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;
import '../../firebase_options.dart';
import 'auth_user.dart';
import 'auth_provider.dart';
import 'auth_exceptions.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user != null) return user;
      throw UserNotLoggedInAuthException();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') throw UserNotFoundAuthException();
      else if (e.code == 'wrong-password') throw WrongPasswordAuthException();
      else throw GenericAuthException();
    } catch (_) {
      throw GenericAuthException();
    }
  }
  
  @override
  Future<AuthUser> createUser({required String email, required String password}) {
    // TODO: implement createUser
    throw UnimplementedError();
  }
  
  @override
  Future<void> logOut() {
    // TODO: implement logOut
    throw UnimplementedError();
  }
  
  @override
  Future<void> sendEmailVerification() {
    // TODO: implement sendEmailVerification
    throw UnimplementedError();
  }
}