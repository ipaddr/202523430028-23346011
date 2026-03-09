import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// PASTIKAN DUA IMPORT INI ADA (Sesuaikan dengan nama folder project-mu jika ada error)
import '../constants/routes.dart'; 
import '../utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text('Register')),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false, // Tambahan: agar tidak ada sugesti kata (karena ini email)
            autocorrect: false, // Tambahan: agar email tidak di-autocorrect
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'Enter email'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false, // Tambahan: agar password tidak ada sugesti
            autocorrect: false, // Tambahan: agar password tidak di-autocorrect
            decoration: const InputDecoration(hintText: 'Enter password'),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              
              try {
                // 1. Proses Register Firebase
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                
                // 2. Jika SUKSES: Lempar ke layar verifikasi email
                Navigator.of(context).pushNamed(verifyEmailRoute);
                
              } on FirebaseAuthException catch (e) {
                // 3. Jika GAGAL (Error Firebase): Munculkan Dialog
                if (e.code == 'weak-password') {
                  await showErrorDialog(context, 'Weak password');
                } else if (e.code == 'email-already-in-use') {
                  await showErrorDialog(context, 'Email is already in use');
                } else if (e.code == 'invalid-email') {
                  await showErrorDialog(context, 'Invalid email entered');
                } else {
                  await showErrorDialog(context, 'Error: ${e.code}');
                }
              } catch (e) {
                // 4. Jika GAGAL (Error umum di luar Firebase): Munculkan Dialog
                await showErrorDialog(context, e.toString());
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
            onPressed: () {
              // 5. Gunakan konstanta rute yang lebih aman
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute, 
                (route) => false,
              );
            },
            child: const Text('Already registered? Login here!'),
          )
        ],
      ),
    );
  }
}