// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:keyboard_typing_speed/main.dart';

void main() {
  testWidgets('Typing Speed App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TypingSpeedApp());

    // Verify that our app starts by checking for the title.
    expect(find.text('Typing Speed Tester'), findsOneWidget);

    // Example of a failing test: Verify that a widget that doesn't exist is not found.
    // expect(find.text('Non-existent widget'), findsOneWidget);
  });
}
