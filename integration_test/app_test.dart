import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:loginpage/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Integration Test', () {
    testWidgets('Verify app opens on Login screen and validates form elements', (WidgetTester tester) async {
      // 1. Launch full application
      app.main();
      await tester.pumpAndSettle();

      // 2. Check Login screen UI components
      expect(find.text('Login'), findsWidgets);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      expect(find.text("Don't have an account? Register"), findsOneWidget);

      // 3. Test empty validation
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter email and password'), findsOneWidget);
    });
  });
}
