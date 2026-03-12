import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Menggunakan Absolute Import agar tidak pernah error path
import 'package:mynoteku/firebase_options.dart';
import 'package:mynoteku/constants/routes.dart'; // Ini yang menyembuhkan error route
import 'package:mynoteku/views/login_view.dart';
import 'package:mynoteku/views/register_view.dart';
import 'package:mynoteku/views/notes_view.dart';
import 'package:mynoteku/views/verify_email_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Notes',
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            
            if (user != null) {
              if (user.emailVerified) {
                return const NotesView(); 
              } else {
                return const VerifyEmailView(); 
              }
            } else {
              return const LoginView();
            }
            
          default:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
        }
      },
    );
  }
}