import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volta/screens/home_screen/home_screen.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('HomeScreen displays correctly', (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Verify that the app bar is displayed
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Tool App'), findsOneWidget);

      // Verify that the sidebar is displayed
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(5));

      // Verify that the variable section is displayed
      expect(find.text('Variables for Tool 1'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));

      // Verify that the output section is displayed
      expect(find.text('Output'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Selecting a tool updates the variable section',
        (WidgetTester tester) async {
      // Build the HomeScreen widget
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Tap on the second tool in the sidebar
      await tester.tap(find.text('Tool 2'));
      await tester.pumpAndSettle();

      // Verify that the variable section is updated
      expect(find.text('Variables for Tool 2'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
    });
  });
}
