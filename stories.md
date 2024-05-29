## Story 1:

- When the users open the app, they see the Home screen.
- On the Home screen, users see a list of tool names.
- The list of tool names is a constant for demo purpose.
- By default, users see the first tool in the list is selected.
- Users can click on other tool names to switch the selected tool.
- When a tool name is selected, users see a list of variables that the tool requires.
- For demo purpose, each tool has a fix list of variables.
- On the Home screen, users also see the output text area where the output when running a tool is displayed.

## Story 2:

- When users open the app, they see the Home screen.
- On the Home screen, users see a list of tool names.
- The list of tool names is loaded from a JSON file in the asset bundle.
- The JSON file contains a list of tools, each tool has the name, the description, the id.

## Story 3:

- Addition to existing UI of the Home screen, users should see the info icon at the end of each tool item in the list.
- When users hover on the icon, it shows the tool description in the tooltip.

## Story 4:

- Addition to current features, when a tool is selected, the list of variables is loaded from a tool-specific JSON file in the asset bundle.
- The file name is the tool id.
- The JSON file contains the list of variables.
- Each variable contains these information:
  - Name
  - Description
  - Value format: plain text | JSON object
  - Input type: text field | dropdown
  - Source name (If the input type is dropdown)
  - Hint label (to show when the input value is empty)
  - Select label (to show when the input type is dropdown and the input value is empty)

## Story 5:

- Addition to current features, the Home screen should be responsive.
- When the screen width is less than the tablet width:
  - The current side bar should be hidden.
  - There should be a hamburger menu button on the top left of the screen.
  - When users click on the hamburger menu button, the tablet version of the side bar shows up by sliding from the left. It shows on top of the current UI.
  - When the tablet version side bar is opened, it has a collapse button on the top right to slide the side bar to the outside of the UI and show the hamburger menu button again.
  - While the table version side bar is opened, if the screen size is changed to be larger than the tablet width, the states must be reset and the old side bar should be shown.

## Story 6:

- Addition to current features, when the screen is large, the side bar should not show the collapse button on the top right corner.

## Story 7:

- Addition to current features, there should be a navigation rail on the left side of the app.
- The sidebar is placed on the right of the navigation rail.
- The Variable and the Output sections are placed on the right of the sidebar.
- The navigation rail is always display no matter what the screen size is.
- The navigation rails contains 2 items:
  - 1st: A build icon
  - 2nd: A file explorer icon
- The side bar should not contain the list of tool names only anymore. The side bar content should depend on the selected icon on the navigation rail as described below:
  - When the screen width is larger than 800:
    - The side bar is always shown next to the navigation rail.
    - When the build icon is selected on the rail, the side bar shows the list of tool names as how the side bar is currently implemented.
    - When the file explorer icon is selected, the side bar shows a placeholder text.
  - When the screen width is less than 800:
    - The side bar is hidden by default.
    - When an icon on the navigation rail is clicked, the side bar shows up at the front of the current UI, next to the navigation rail.
    - When the same icon is clicked again, the side bar is hidden again.
    - When another icon is clicked while the side bar is showing, the content of the side bar changes. The side bar is still showing.
- Implementation suggestions:
  - The NavigationRail class of `material` package is recommended to use.
  - The SideBar should accept a child widget that shows the content.

## Story 8:

- Addition to the current features.
- When the screen size is less than 800:
  - The side bar is hidden by default.
  - When an icon on the navigation rail is clicked, the side bar is shown next to navigation rail as the current implementation. But the side bar must be placed on the above layer that covers the variable and output sections below.
  - If the current selected icon is clicked, the side bar should disappear.
  - If an icon that is not the current selected icon is clicked while the side bar is showing, the content of the side bar changes. The side bar is still showing.
- When the screen width is larger than 800:
  - The side bar is always shown next to the navigation rail.
  - When the build icon is selected on the rail, the side bar shows the list of tool names as how the side bar is currently implemented.
  - When the file explorer icon is selected, the side bar shows a placeholder text.

## Story 9:

- The File Explorer area should show the Open Folder button when there is no one opened.
- When a folder is opened, it should show the file hierarchy of the folder.
- The File Explorer area should be scrollable in the vertical direction when the content is too long.

## Story 10:

- Click on the Open Project button allows users to select a folder on their machine.
- The file hierarchy of the selected project will be displayed in the File Explorer section.

## Story 11:

- Once the File Explorer has data, the data should not lose when switch to the Tools section.

## Story 12:

- The selected folder content, including sub-directories, in the File Explorer section, should be displayed as a recursive tree.

The content of the selected folder must be displayed recursively. However, current implementation that is using nested ListView is not the expected implementation. It leads to UI layout issue.

## Story 13:

- Only the last path should be used as the name of each item in the file tree.
- When the folder is selected, only the first level content should be displayed. All nested subfolders should be collapsed.
- When users click on a folder, the sub-tree of that folder is expanded.

## Story 14:

- Give this case: If a filepath is either "D:\CodeOnSunday\ai_hub\subdir\pubspec.lock" or "D:/CodeOnSunday/ai_hub/subdir/pubspec.lock", it should be displayed as "pubsec.lock" in the "subdir" folder when the "subdir" folder is expanded and the root selected folder path is "D:\CodeOnSunday\ai_hub". The backward slash or forward slash dividers should not be matter.

## Story 15:

Set hover color of items in the file explorer to light grey.

## Story 16:

Instead of showing the arrow button at the end of each folder row in the file explorer, show it at the beginning of each folder row.
Do the same with the file icon.

## Story 17:

When an item (folder item or file item) in the file explorer is in the selected state, its background color changes to black, content color changes to white.
An item is changed to the selected state if one of these conditions met:

- It's clicked while it's in the unselected state.
- It's clicked while it's in the selected state AND it's a folder item.
  Only one item is in the selected state at a time.

## Story 18:

In addition to current features, implement the multi-select feature. This feature is enabled if the users are holding the Control key on the keyboard. The implementation must detect when the key is pressed.

## Story 19:

When the input type is "Sources", show the drag and drop area that says: "Drag and drop your sources here". Make sure the text grammatically correct.
The implementation should use the standard drag and drop mechanism of Flutter.

## Story 20:

(Must provide the docs at https://docs.flutter.dev/cookbook/effects/drag-a-widget)
As the user long presses on the LongPressDraggable in the FileExplorerSection widget, a collection icon widget appears beneath the user's finger, and the user drags the icon widget to the DragTarget in the variable section and releases it. The DragTarget will receive the list of paths of selected items, which can read from the FileExplorerState, when users release. Since the data should be read from the FileExplorerState, the FileExploreSection must not need to be turned into a StatefulWidget.

The LongPressDraggable must be placed in the FileExplorerSection widget, NOT the variable section.

## Story 21:

Highlight the DragTarget box when the object enters the area. When the object is dropped, show the data as list of string separated by commas.

## Story 22:

Display the relative path to the root folder instead of showing the full path of each item in the variable section that has the "sources" type.

## Story 23:

Show folder icon in the Chip if the selected path is of a folder.

## Story 24:

Show folder icon in the Chip if the selected path is of a folder.

## Story 25:

Click on the chevron icon at the beginning of the folder item will expand it but won't change its selected state.

## Story 26:

While the ctrl key is pressed, clicking on that folder item should only change its selection state and won't change its expansion state.

## Story 27:

When starting to drag content from file explorer, the selected paths should exclude files or folders that are descendants of any selected folders.

## Story 28:

A function that accepts the content of a Git ignore file and a path, return true if the path matches one of rules in the Git ignore content.

Remember that Git ignore supports a wide range of rules. A simple check (e.g. filepath.contain(rule)) is not enough. An external package to handle that still hasn't existed yet.

Add some test cases to cover all possible cases.

## Story 29:

Grey out items that matches the rules in the `.gitignore` file in the root project dir.

## Story 30:

A function that concatenates the content of all files inside the selected paths in the variable section, exceptions files excluded by the gitignore rules. The path that is used to check if it matches the gitignore rules must be the relative path to the root selected folder path of the file explorer.

## Story 31:

Each path in the paths arg of the getConcatenatedContent() function could be a file or a directory. Retrieve all the files.
Concatenated content must contains multiple file content, each file content in the following format:
---<file name>---

```
CONTENT
```

## Story 32:

Show a Run button at the top right corner of the Home Screen. When users click on it, it calls the getConcatenatedContent function

## Story 33:

The getVariables function is obsoleted because the tool-specific JSON file's format changed as the new one provided below. When a tool is selected, the tool-specific JSON file will be loaded to read the prompt and variables from. The new format here:

````
{
  "prompt": "Given this existing implementation:\n<implementation>\n{{IMPLEMENTATION}}\n</implementation>\n\nApplying the vanilla state management solution of Flutter, modify the implementation to satisfy the feature below:\n<feature>\n{{FEATURE}}\n</feature>\n\nSome minimum requirements you MUST follow:\n- Errors must be logged or displayed to the UI.\n- If your response mentions a file in the implementation, the file name must be in snake case.\n- Only include the modified files in your response.\n\nRemember that the source code of each file in your response must be wrapped in a Markdown code block to be well formatted.\n\nThe response must contains multiple parts, each part has the following format:\n---<File name>---\n```dart\nSource code\n```",
  "variables": [
    {
      "description": "Files that contains the implementation",
      "hint_label": "Provide files that contains the implementation",
      "input_type": "sources",
      "name": "IMPLEMENTATION",
      "value_format": "text"
    },
    {
      "description": "Detailed requirements",
      "hint_label": "Enter your detailed requirements",
      "input_type": "text_field",
      "name": "REQUIREMENTS",
      "value_format": "text"
    }
  ]
}
````

## Story 34:

Store the input value of each field, so that when the Run button is pressed, instead of calling the getConcatenatedContent function, it prints out the values of each field.

## Story 35:

The selected paths of each "sources" field should be kept separated by variable name. When the submit() function is called, the getConcatenatedContent function will be called on each "sources" field to print out the content.

## Story 36:

In the submit() function, create the prompt message by replacing placeholders (.e.g. "{{IMPLEMENTATION}}") by the corresponding variable value in the \_inputValues or \_concatenatedContents. The placeholder names should be generic.

## Story 37:

In the submit() function, call the Anthropic API to send the prompt and get the response message by using the anthropic_sdk_dart (the documentation below)

## Story 38:

There should be a Settings button on the navigation rail that has the UI to let users to input their Anthropic API key. The key then should be persisted on the machine.

## Story 39:

When submit, it should use the key read from the api key manager. Then, the response text should show in the output section. While waiting for the response, the text "Run" inside the Run button should be replaced by a circular loading indicator.

## Story 40:

All the content of the variable section needs to be hidden by default. The visibility of the section now is controlled by a button on top of the HomeScreen.

When clicking on the Show input button, the card that contains the variable section content must slide from the outer right of the screen into the screen and align to the right of the screen.

## Story 41:

The "Clear values" button should clear all variables, especially the text fields.

To implement, the VariableInput needs to listen to the clear event that will be emitted from a stream in the VariableSectionState to clear values in TextController

## Story 42:

Show another Run button next to the variables toggle button on the home screen

## Story 43:

Implement a CodeWrapper that shows a Copy button on the top right of the child widget.

```
typedef CodeWrapper = Widget Function(
  Widget child,
  String code,
  String language,
);
```
