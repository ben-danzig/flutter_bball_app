import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bball_app/screens/auth/auth_wrapper.dart';
import 'package:flutter_bball_app/screens/auth/login_screen.dart';
import 'package:flutter_bball_app/screens/home_screen.dart';
import 'package:flutter_bball_app/services/auth_service.dart';
import '../mocks/mock_auth_service.dart';

void main() {
  group('AuthWrapper Widget Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    Widget createTestWidget({required MockAuthService authService}) {
      return MaterialApp(
        home: ChangeNotifierProvider<AuthService>(
          create: (_) => authService,
          child: const AuthWrapper(),
        ),
      );
    }

    testWidgets('shows LoginScreen when user is not authenticated', (tester) async {
      // Arrange: Set up unauthenticated state
      mockAuthService.setUnauthenticated();

      // Act: Build widget
      await tester.pumpWidget(createTestWidget(authService: mockAuthService));

      // Assert: Verify LoginScreen is displayed
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('shows HomeScreen when user is authenticated', (tester) async {
      // Arrange: Set up authenticated state
      mockAuthService.setAuthenticatedUser(
        email: 'test@example.com',
        displayName: 'Test User'
      );

      // Act: Build widget
      await tester.pumpWidget(createTestWidget(authService: mockAuthService));

      // Assert: Verify HomeScreen is displayed
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('switches from LoginScreen to HomeScreen when user logs in', (tester) async {
      // Arrange: Start unauthenticated
      mockAuthService.setUnauthenticated();
      await tester.pumpWidget(createTestWidget(authService: mockAuthService));
      
      // Verify starting state
      expect(find.byType(LoginScreen), findsOneWidget);

      // Act: Simulate user login
      mockAuthService.setAuthenticatedUser(email: 'newuser@example.com');
      await tester.pump(); // Rebuild after state change

      // Assert: Verify navigation to HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('switches from HomeScreen to LoginScreen when user logs out', (tester) async {
      // Arrange: Start authenticated
      mockAuthService.setAuthenticatedUser(email: 'user@example.com');
      await tester.pumpWidget(createTestWidget(authService: mockAuthService));
      
      // Verify starting state
      expect(find.byType(HomeScreen), findsOneWidget);

      // Act: Simulate user logout
      mockAuthService.setUnauthenticated();
      await tester.pump(); // Rebuild after state change

      // Assert: Verify navigation to LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('responds correctly to multiple auth state changes', (tester) async {
      // Arrange: Start unauthenticated
      mockAuthService.setUnauthenticated();
      await tester.pumpWidget(createTestWidget(authService: mockAuthService));
      expect(find.byType(LoginScreen), findsOneWidget);

      // Act & Assert: Multiple state changes
      
      // Login
      mockAuthService.setAuthenticatedUser(email: 'user1@example.com');
      await tester.pump();
      expect(find.byType(HomeScreen), findsOneWidget);
      
      // Logout
      mockAuthService.setUnauthenticated();
      await tester.pump();
      expect(find.byType(LoginScreen), findsOneWidget);
      
      // Login again with different user
      mockAuthService.setAuthenticatedUser(email: 'user2@example.com');
      await tester.pump();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
} 