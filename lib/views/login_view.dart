import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// PASTIKAN DUA IMPORT INI ADA
import '../constants/routes.dart';
import '../utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Enter your email here',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true, 
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Enter your password here',
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              
              try {
                // 1. Proses login ke Firebase
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                
                // 2. Tarik data user yang baru saja login
                final user = FirebaseAuth.instance.currentUser;
                
                // 3. Confirming Identity (Cek apakah email sudah diverifikasi)
                if (user?.emailVerified ?? false) {
                  // Jika SUDAH diverifikasi -> Masuk ke layar Notes
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute, 
                    (route) => false,
                  );
                } else {
                  // Jika BELUM diverifikasi -> Lempar ke layar Verifikasi Email
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmailRoute, 
                    (route) => false,
                  );
                }

              } on FirebaseAuthException catch (e) {
                // 4. Ubah print() menjadi showErrorDialog()
                if (e.code == 'user-not-found') {
                  await showErrorDialog(context, 'User not found');
                } else if (e.code == 'wrong-password') {
                  await showErrorDialog(context, 'Wrong credentials');
                } else {
                  await showErrorDialog(context, 'Error: ${e.code}');
                }
              } catch (e) {
                await showErrorDialog(context, e.toString());
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              // 5. Ubah string manual menjadi konstanta rute
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute, 
                (route) => false,
              );
            },
            child: const Text('Not registered yet? Register here!'),
          )
        ],
      ),
    );
  }
}