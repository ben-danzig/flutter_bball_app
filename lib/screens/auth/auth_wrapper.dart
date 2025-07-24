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
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final currentUser = authService.currentUser;
        final isAuthenticated = authService.isAuthenticated;
        
        print('[AuthWrapper] AuthService state - isAuthenticated: $isAuthenticated, currentUser: ${currentUser?.uid}');
        
        // Simple logic: if authenticated and has user, show home screen
        if (isAuthenticated && currentUser != null) {
          print('[AuthWrapper] User authenticated, showing home screen');
          return const HomeScreen();
        }
        
        // Otherwise, show login screen
        print('[AuthWrapper] User not authenticated, showing login screen');
        return const LoginScreen();
      },
    );
  }
} 