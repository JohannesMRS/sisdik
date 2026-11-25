import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('Layar health SISDIK ditampilkan', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('SISDIK'), findsOneWidget);
    expect(find.text('Periksa Koneksi'), findsOneWidget);
  });
}
