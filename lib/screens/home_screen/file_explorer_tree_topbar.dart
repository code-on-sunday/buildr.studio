import 'package:buildr_studio/screens/home_screen/file_explorer_state.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FileExplorerTreeTopbar extends StatelessWidget {
  const FileExplorerTreeTopbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final fileExplorerTreeState = context.watch<FileExplorerState>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ShadTooltip(
            builder: (_) => Text(fileExplorerTreeState.selectedFolderPath!),
            child: Text(
              'Explorer: ${path.basename(fileExplorerTreeState.selectedFolderPath!)}',
              style: ShadTheme.of(context).textTheme.list,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        const SizedBox(width: 4),
        if (fileExplorerTreeState.selectedFolderPath != null)
          ShadTooltip(
            builder: (_) => const Text('Refresh'),
            child: ShadButton.ghost(
              onPressed: () {
                fileExplorerTreeState.loadStoredLastWorkingDir();
              },
              size: ShadButtonSize.icon,
              width: 24,
              height: 24,
              icon: const Icon(
                Icons.refresh_sharp,
                size: 16,
              ),
            ),
          ),
        if (fileExplorerTreeState.selectedFolderPath != null)
          ShadTooltip(
            builder: (_) => const Text('New file'),
            child: ShadButton.ghost(
              onPressed: () async {
                final fileName =
                    await enterTargetName(context, 'Enter file name');
                if (fileName == null) return;
                fileExplorerTreeState.createNewFile(fileName);
              },
              size: ShadButtonSize.icon,
              width: 24,
              height: 24,
              icon: const Icon(
                Icons.note_add_sharp,
                size: 16,
              ),
            ),
          ),
        if (fileExplorerTreeState.selectedFolderPath != null)
          ShadTooltip(
            builder: (_) => const Text('New folder'),
            child: ShadButton.ghost(
              onPressed: () async {
                final folderName =
                    await enterTargetName(context, 'Enter folder name');
                if (folderName == null) return;
                fileExplorerTreeState.createNewFolder(folderName);
              },
              size: ShadButtonSize.icon,
              width: 24,
              height: 24,
              icon: const Icon(Icons.create_new_folder_sharp, size: 16),
            ),
          ),
        ShadPopover(
            controller: fileExplorerTreeState.popOverController,
            child: ShadButton.outline(
              onPressed: () {
                fileExplorerTreeState.popOverController.show();
              },
              icon: const Icon(Icons.more_vert),
            ),
            popover: (_) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShadButton.ghost(
                      onPressed: () {
                        fileExplorerTreeState.popOverController.hide();
                        fileExplorerTreeState.openFolder();
                      },
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.folder_open),
                      ),
                      text: const Text('Open project'),
                    ),
                    ShadButton.ghost(
                      onPressed: () {
                        fileExplorerTreeState.popOverController.hide();
                        fileExplorerTreeState.createNewProject(() {
                          return enterTargetName(context, 'Enter project name');
                        });
                      },
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.add),
                      ),
                      text: const Text('New project'),
                    ),
                  ],
                )),
      ],
    );
  }
}

Future<String?> enterTargetName(BuildContext context, String title) {
  return showShadDialog<String>(
    context: context,
    builder: (context) {
      String? targetName;
      return StatefulBuilder(builder: (context, setState) {
        return ShadDialog(
          content: Column(
            children: [
              Text(title),
              ShadInputFormField(
                autofocus: true,
                onChanged: (value) => setState(
                  () => targetName = value,
                ),
                onSubmitted: (value) {
                  Navigator.pop(context, targetName);
                },
              )
            ],
          ),
          actions: [
            ShadButton.destructive(
              onPressed: () {
                Navigator.pop(context);
              },
              text: const Text('Cancel'),
            ),
            ShadButton(
              onPressed: () {
                Navigator.pop(context, targetName);
              },
              text: const Text('Confirm'),
            ),
          ],
        );
      });
    },
  );
}
