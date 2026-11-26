import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/features/main_shell_screen.dart';

void main() {
  testWidgets('Layar login SISDIK ditampilkan', (WidgetTester tester) async {
    final auth = AuthProvider();
    auth.status = AuthStatus.unauthenticated;

    await tester.pumpWidget(MyApp(auth: auth));
    await tester.pumpAndSettle();

    expect(find.text('SISDIK'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('Bottom navigation tiga tab ditampilkan', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainShellScreen()));
    await tester.pump(const Duration(seconds:11));

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Courses'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
