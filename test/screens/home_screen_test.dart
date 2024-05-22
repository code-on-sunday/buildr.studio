import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:volta/models/tool.dart';
import 'package:volta/repositories/tool_repository.dart';
import 'package:volta/screens/home_screen/home_screen.dart';

import 'home_screen_test.mocks.dart';

@GenerateMocks([ToolRepository])
void main() {
  group('HomeScreen', () {
    late MockToolRepository mockToolRepository;

    setUp(() {
      mockToolRepository = MockToolRepository();
      GetIt.I.registerSingleton<ToolRepository>(mockToolRepository);
    });

    tearDown(() {
      GetIt.I.unregister<ToolRepository>();
    });

    testWidgets('HomeScreen displays correctly', (WidgetTester tester) async {
      // Arrange
      final tools = [
        Tool(
          id: 'tool1',
          name: 'Tool 1',
          description: 'This is the first tool.',
          variables: ['Variable 1', 'Variable 2', 'Variable 3'],
        ),
        Tool(
          id: 'tool2',
          name: 'Tool 2',
          description: 'This is the second tool.',
          variables: ['Variable 4', 'Variable 5', 'Variable 6'],
        ),
        Tool(
          id: 'tool3',
          name: 'Tool 3',
          description: 'This is the third tool.',
          variables: ['Variable 7', 'Variable 8', 'Variable 9'],
        ),
      ];
      when(mockToolRepository.getTools()).thenAnswer((_) async => tools);

      // Act
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.text('Variables for Tool 1'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.text('Output'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Selecting a tool updates the variable section',
        (WidgetTester tester) async {
      // Arrange
      final tools = [
        Tool(
          id: 'tool1',
          name: 'Tool 1',
          description: 'This is the first tool.',
          variables: ['Variable 1', 'Variable 2', 'Variable 3'],
        ),
        Tool(
          id: 'tool2',
          name: 'Tool 2',
          description: 'This is the second tool.',
          variables: ['Variable 4', 'Variable 5', 'Variable 6'],
        ),
        Tool(
          id: 'tool3',
          name: 'Tool 3',
          description: 'This is the third tool.',
          variables: ['Variable 7', 'Variable 8', 'Variable 9'],
        ),
      ];
      when(mockToolRepository.getTools()).thenAnswer((_) async => tools);

      // Act
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tool 2'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Variables for Tool 2'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
    });
  });
}
