import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:loginpage/views/login_screen.dart';
import 'package:loginpage/viewmodels/auth_viewmodel.dart';
import 'package:loginpage/viewmodels/task_viewmodel.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('Renders Email, Password fields and Login button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      // Verify AppBar title
      expect(find.text('Login'), findsWidgets);

      // Verify TextFields exist
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Verify Login button exists
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

      // Verify Register text button exists
      expect(find.text("Don't have an account? Register"), findsOneWidget);
    });

    testWidgets('Entering text into Email and Password fields updates value', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);

      // Enter email
      await tester.enterText(textFields.first, 'test@example.com');
      // Enter password
      await tester.enterText(textFields.last, 'password123');

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('Clicking Login with empty fields shows validation SnackBar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      // Tap Login button directly without filling fields
      final loginBtn = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginBtn);
      await tester.pump(); // trigger frame for SnackBar

      // Verify SnackBar appears
      expect(find.text('Please enter email and password'), findsOneWidget);
    });
  });
}
