import 'package:buildr_studio/models/tool.dart';
import 'package:buildr_studio/models/variable.dart';
import 'package:buildr_studio/repositories/tool_repository.dart';
import 'package:buildr_studio/screens/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../test_utils.dart';
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

    testGoldens('HomeScreen displays correctly', (WidgetTester tester) async {
      // Arrange
      final tools = [
        Tool(
          id: 'new_functionalities',
          name: 'Add new functionalities',
          description: 'Add new functionalities to existing implementation',
        ),
        Tool(
          id: 'tool2',
          name: 'Tool 2',
          description: 'This is the second tool.',
        ),
        Tool(
          id: 'tool3',
          name: 'Tool 3',
          description: 'This is the third tool.',
        ),
      ];
      final variables = [
        Variable(
          name: 'Implementation',
          description: 'Existing implementation',
          valueFormat: 'text',
          inputType: 'text_field',
          hintLabel: 'Insert the existing implementation here',
        ),
      ];
      when(mockToolRepository.getTools()).thenAnswer((_) async => tools);
      when(mockToolRepository.getVariables('new_functionalities'))
          .thenAnswer((_) async => variables);

      // Act
      await tester.pumpWidgetBuilder(const HomeScreen());
      await tester.pumpAndSettle();

      // Assert
      await multiScreenGolden(tester, 'HomeScreen displays correctly');
    });

    testGoldens('Selecting a tool updates the variable section',
        (WidgetTester tester) async {
      // Arrange
      final tools = [
        Tool(
          id: 'new_functionalities',
          name: 'Add new functionalities',
          description: 'Add new functionalities to existing implementation',
        ),
        Tool(
          id: 'tool2',
          name: 'Tool 2',
          description: 'This is the second tool.',
        ),
        Tool(
          id: 'tool3',
          name: 'Tool 3',
          description: 'This is the third tool.',
        ),
      ];
      final variables1 = [
        Variable(
          name: 'Implementation',
          description: 'Existing implementation',
          valueFormat: 'text',
          inputType: 'text_field',
          hintLabel: 'Insert the existing implementation here',
        ),
      ];
      final variables2 = [
        Variable(
          name: 'Variable 1',
          description: 'This is the first variable.',
          valueFormat: 'text',
          inputType: 'text_field',
          hintLabel: 'Enter Variable 1',
        ),
        Variable(
          name: 'Variable 2',
          description: 'This is the second variable.',
          valueFormat: 'text',
          inputType: 'text_field',
          hintLabel: 'Enter Variable 2',
        ),
        Variable(
          name: 'Variable 3',
          description: 'This is the third variable.',
          valueFormat: 'text',
          inputType: 'text_field',
          hintLabel: 'Enter Variable 3',
        ),
      ];
      when(mockToolRepository.getTools()).thenAnswer((_) async => tools);
      when(mockToolRepository.getVariables('new_functionalities'))
          .thenAnswer((_) async => variables1);
      when(mockToolRepository.getVariables('tool2'))
          .thenAnswer((_) async => variables2);

      // Act
      await tester.pumpWidgetBuilder(const HomeScreen(),
          surfaceSize: Screens.desktop);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tool 2'));
      await tester.pumpAndSettle();

      // Assert
      await screenMatchesGolden(
          tester, 'Selecting a tool updates the variable section');
    });

    testGoldens('HomeScreen displays variables for the selected tool',
        (WidgetTester tester) async {
      // Arrange
      final tools = [
        Tool(
          id: 'new_functionalities',
          name: 'Add new functionalities',
          description: 'Add new functionalities to existing implementation',
        ),
        Tool(
          id: 'tool2',
          name: 'Tool 2',
          description: 'This is the second tool.',
        ),
        Tool(
          id: 'tool3',
          name: 'Tool 3',
          description: 'This is the third tool.',
        ),
      ];
      final variables = [
        Variable(
          name: 'Implementation',
          description: 'Existing implementation',
          valueFormat: 'text',
          inputType: 'text_field',
          hintLabel: 'Insert the existing implementation here',
        ),
      ];
      when(mockToolRepository.getTools()).thenAnswer((_) async => tools);
      when(mockToolRepository.getVariables('new_functionalities'))
          .thenAnswer((_) async => variables);

      // Act
      await tester.pumpWidgetBuilder(const HomeScreen(),
          surfaceSize: Screens.desktop);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add new functionalities'));
      await tester.pumpAndSettle();

      // Assert
      await screenMatchesGolden(
          tester, 'HomeScreen displays variables for the selected tool');
    });

    testGoldens('HomeScreen displays dropdown for variables with select label',
        (WidgetTester tester) async {
      // Arrange
      final tools = [
        Tool(
          id: 'new_functionalities',
          name: 'Add new functionalities',
          description: 'Add new functionalities to existing implementation',
        ),
      ];
      final variables = [
        Variable(
          name: 'Implementation',
          description: 'Existing implementation',
          valueFormat: 'text',
          inputType: 'dropdown',
          hintLabel: 'Select implementation',
          selectLabel: 'Select an option',
          sourceName: 'Option 1, Option 2, Option 3',
        ),
      ];
      when(mockToolRepository.getTools()).thenAnswer((_) async => tools);
      when(mockToolRepository.getVariables('new_functionalities'))
          .thenAnswer((_) async => variables);

      // Act
      await tester.pumpWidgetBuilder(const HomeScreen(),
          surfaceSize: Screens.desktop);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add new functionalities'));
      await tester.pumpAndSettle();

      // Assert
      await screenMatchesGolden(tester,
          'HomeScreen displays dropdown for variables with select label');
    });
  });
}
