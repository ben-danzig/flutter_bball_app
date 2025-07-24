import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bball_app/screens/auth/login_screen.dart';
import 'package:flutter_bball_app/services/auth_service.dart';
import '../mocks/mock_auth_service.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    Widget createTestWidget({required MockAuthService authService}) {
      return MaterialApp(
        home: ChangeNotifierProvider<AuthService>(
          create: (_) => authService,
          child: const LoginScreen(),
        ),
      );
    }

    group('Form Validation Tests', () {
      testWidgets('shows validation errors for empty fields', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(authService: mockAuthService));

        // Act: Try to submit empty form
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        // Assert: Validation messages should appear
        expect(find.text('Please enter your email'), findsOneWidget);
        expect(find.text('Please enter your password'), findsOneWidget);
      });

      testWidgets('shows error for invalid email format', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(authService: mockAuthService));

        // Act: Enter invalid email
        await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        // Assert: Email validation error should appear
        expect(find.text('Please enter a valid email'), findsOneWidget);
      });

      testWidgets('has basic UI elements', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(authService: mockAuthService));

        // Assert: Basic form elements are present
        expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.byType(Form), findsOneWidget);
      });

      testWidgets('email field accepts text input', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(authService: mockAuthService));

        // Act: Enter text in email field
        await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');

        // Assert: Text should be entered
        expect(find.text('test@example.com'), findsOneWidget);
      });

      testWidgets('password field accepts text input', (tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(authService: mockAuthService));

        // Act: Enter text in password field
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.pump();

        // Assert: Password field should have content (we can't see the actual text due to obscuring)
        final passwordField = tester.widget<TextFormField>(find.byType(TextFormField).at(1));
        expect(passwordField.controller?.text, equals('password123'));
      });
    });
  });
} 