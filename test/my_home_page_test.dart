import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xo/main.dart';

void main() {
  testWidgets('Score display test', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MyApp());

    // Verify that the initial score for X and O is 0
    expect(find.text('Score: X - 0 | O - 0'), findsOneWidget);

    // Simulate a tap on the first grid tile (index 0) to make X's move
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump();

    // Verify that the score remains the same since no one has won yet
    expect(find.text('Score: X - 0 | O - 0'), findsOneWidget);

    // Simulate a tap on the second grid tile (index 1) to make O's move
    await tester.tap(find.byType(GestureDetector).at(1));
    await tester.pump();

    // Verify that the score still remains the same
    expect(find.text('Score: X - 0 | O - 0'), findsOneWidget);
  });
}