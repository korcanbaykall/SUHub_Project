import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suhub/routes.dart';
import 'package:suhub/screens/welcome_screen.dart';

void main() {
  testWidgets('WelcomeScreen shows title and buttons', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    expect(find.text('Welcome to SUHub'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('tapping Sign In navigates to signin route', (tester) async {
    await tester.pumpWidget(MaterialApp(
      routes: {
        AppRoutes.signin: (_) => const Scaffold(body: Text('Sign In Page')),
        AppRoutes.signup: (_) => const Scaffold(body: Text('Sign Up Page')),
      },
      home: const WelcomeScreen(),
    ));

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Sign In Page'), findsOneWidget);
  });
}
