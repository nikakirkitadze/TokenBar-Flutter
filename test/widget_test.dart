import 'package:flutter_test/flutter_test.dart';
import 'package:tokenbar_flutter/app.dart';

void main() {
  testWidgets('TokenBar app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TokenBarApp());
    expect(find.text('TokenBar'), findsOneWidget);
  });
}
