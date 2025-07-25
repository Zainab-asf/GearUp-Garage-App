// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:login/customer/customer_login.dart';
import 'package:login/customer/customer_signup.dart';
import 'package:login/customer/customer_home.dart';

void main() {
  testWidgets('Login app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "GearUp",
        initialRoute: 'login',
        routes: {
          'login': (context) => const MyLogin(),
          'signup': (context) => const MySignup(),
          'home': (context) => const MyHome(),
        },
      ),
    );

    // Verify that the login page loads
    expect(find.byType(MyLogin), findsOneWidget);
  });
}
