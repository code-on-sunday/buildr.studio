Refactor to move functions into a ChangeNotifier class that will be used internally by the HomeScreen widget. The HomeScreen will be rebuilt by listening to the ChangeNotifier, so the HomeScreen should turn into a StatelessWidget. The HomeScreenState should be created in the ChangeNotifierProvider. The HomeScreenState constructor can accept the BuildContext so that it can use for internal logic. Other dependencies of the HomeScreenState should be provided by get_it from inside the class.

---

Make item names in the File Explorer less bold and smaller. Reduce the vertical padding to make the list as concise as possible. Considering replace ListTile by other widgets to achieve that. You MUST keep these existing features:

- Clicking on the whole folder row can expand it.
- At the end of the folder row must still show the arrow.
- At the end of the file row must still show the file icon.

---

The direct items of an expanded folder must be shorted by types (Folder to Files), then by A-Z.

---

Refactor to lift the state of the file or folder selection in the FileExplorerSection up to the HomeScreen. A new ChangeNotifier class can be created if needed.
