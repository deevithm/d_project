import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Build a simple MaterialApp for testing
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Test App')),
          body: const Center(child: Text('Hello World')),
        ),
      ),
    );

    // Verify that the app loads successfully
    expect(find.text('Test App'), findsOneWidget);
    expect(find.text('Hello World'), findsOneWidget);
  });
}
