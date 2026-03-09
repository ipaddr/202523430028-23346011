import 'package:test/test.dart';
import 'package:mynoteku/services/auth/auth_provider.dart';
import 'package:mynoteku/services/auth/auth_user.dart';
import 'package:mynoteku/services/auth/auth_exceptions.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();

    test('Harus dimulai dalam keadaan belum diinisialisasi', () {
      expect(provider.isInitialized, false);
    });

    test('Tidak bisa logOut jika belum diinisialisasi', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Harus bisa diinisialisasi', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });
  });
}

// ==========================================
// KELAS TIRUAN (MOCK) UNTUK MENGGANTIKAN FIREBASE
// ==========================================
class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1)); // Pura-pura loading
    _isInitialized = true;
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<AuthUser> logIn({required String email, required String password}) async {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    
    // Pura-pura berhasil login
    _user = const AuthUser(isEmailVerified: false);
    return _user!;
  }

  @override
  Future<AuthUser> createUser({required String email, required String password}) async {
    // Logika pura-pura register
    return await logIn(email: email, password: password);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    _user = const AuthUser(isEmailVerified: true);
  }
}