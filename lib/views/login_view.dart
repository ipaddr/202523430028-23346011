import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynoteku/constants/routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Ini adalah bagian yang terhapus di kodemu (membuat controller)
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
      appBar: AppBar(title: const Text('Login')),
      body: Column(
        children: [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'Email'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Password'),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                
                final user = FirebaseAuth.instance.currentUser;
                if (user?.emailVerified ?? false) {
                  Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);
                }
              } on FirebaseAuthException catch (e) {
                print(e.code);
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
            child: const Text('Not registered yet? Register here!'),
          )
        ],
      ),
    );
  }
}