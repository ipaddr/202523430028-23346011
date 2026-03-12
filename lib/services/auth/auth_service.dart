// lib/services/auth/auth_service.dart
import 'auth_provider.dart';
import 'auth_user.dart';
import 'firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  // Jika kita butuh firebase, panggil ini:
  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<void> initialize() => provider.initialize();

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({required String email, required String password}) =>
      provider.logIn(email: email, password: password);
      
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