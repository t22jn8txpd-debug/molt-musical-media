import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:molt_musical_media/app/services.dart';
import 'package:molt_musical_media/features/auth/signup_screen.dart';

void main() {
  testWidgets('Signup validates required fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SignupScreen(services: AppServices()),
      ),
    );

    await tester.tap(find.text('Create Account'));
    await tester.pump();

    expect(find.text('All fields are required.'), findsOneWidget);
  });
}
