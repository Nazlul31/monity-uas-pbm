// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:monity/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MonityApp());

    // Verify that our app bar shows the test bed title.
    expect(find.text('Monity Test Bed'), findsOneWidget);

    // Verify that the initial balance is calculated and displayed correctly.
    // Total: 5,000,000 - 1,500,000 - 50,000 = 3,450,000
    expect(find.text('Rp 3450000'), findsOneWidget);
  });
}
