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
