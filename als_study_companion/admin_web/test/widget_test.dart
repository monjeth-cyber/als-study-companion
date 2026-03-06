import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Admin web smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('ALS Admin Panel'))),
    );
    expect(find.text('ALS Admin Panel'), findsOneWidget);
  });
}
