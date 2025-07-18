import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bball_app/services/auth_service.dart';
import 'package:flutter_bball_app/screens/home_screen.dart';
import 'package:flutter_bball_app/screens/auth/login_screen.dart';
import 'package:flutter_bball_app/screens/auth/loading_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }
        
        return const LoginScreen();
      },
    );
  }
} 