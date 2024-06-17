import 'dart:io';

import 'package:buildr_studio/screens/home_screen/file_explorer_state.dart';
import 'package:buildr_studio/utils/git_ignore_checker.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FileExplorerTab extends StatefulWidget {
  const FileExplorerTab({super.key});

  @override
  State<FileExplorerTab> createState() => _FileExplorerTabState();
}

class _FileExplorerTabState extends State<FileExplorerTab> {
  final _gitIgnoreChecker = GetIt.I.get<GitIgnoreChecker>();
  final _popOverController = ShadPopoverController();

  @override
  void dispose() {
    _popOverController.dispose();
    super.dispose();
  }

  Widget _buildFileSystemEntityTile(
    BuildContext context,
    FileSystemEntity entity,
    int level,
    FileExplorerState fileExplorerState,
  ) {
    final fileName = fileExplorerState.getDisplayFileName(entity.path);
    final isSelected = fileExplorerState.isSelected[entity.path] ?? false;
    final isExpanded = fileExplorerState.isExpanded[entity.path] ?? false;
    var normalizedPath =
        '${path.separator}${path.relative(entity.path, from: fileExplorerState.selectedFolderPath!)}';
    if (entity is Directory) {
      normalizedPath += path.separator;
    }
    final isIgnored = fileExplorerState.gitIgnoreContent == null
        ? false
        : _gitIgnoreChecker.isPathIgnored(
            fileExplorerState.gitIgnoreContent!,
            normalizedPath,
          );

    final theme = ShadTheme.of(context);

    return ContextMenuRegion(
      behavior: const [ContextMenuShowBehavior.secondaryTap],
      contextMenu: GenericContextMenu(buttonConfigs: [
        ContextMenuButtonConfig('Paste', onPressed: () {
          if (!isIgnored) {
            _pasteClipboardContent(context, entity, fileExplorerState);
          }
        }),
        ContextMenuButtonConfig('Open in VSCode', onPressed: () {
          _openInVSCode(entity);
        }),
      ]),
      child: MouseRegion(
        cursor:
            isIgnored ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        child: Draggable<bool>(
          data: true,
          dragAnchorStrategy: pointerDragAnchorStrategy,
          feedback: const CollectionIcon(),
          onDragStarted: () {
            final isSelected =
                fileExplorerState.isSelected[entity.path] == true;
            if (!isSelected) {
              fileExplorerState.toggleSelection(entity);
            }
          },
          child: ShadButton.ghost(
            height: 32,
            padding: const EdgeInsets.all(0),
            decoration: const ShadDecoration(
              secondaryBorder: ShadBorder.none,
            ),
            enabled: !isIgnored,
            width: double.infinity,
            mainAxisAlignment: MainAxisAlignment.start,
            hoverBackgroundColor:
                isSelected ? theme.colorScheme.primary.withOpacity(0.9) : null,
            backgroundColor:
                isSelected ? theme.colorScheme.primary : Colors.transparent,
            foregroundColor:
                isSelected ? theme.colorScheme.primaryForeground : null,
            hoverForegroundColor:
                isSelected ? theme.colorScheme.primaryForeground : null,
            onPressed: () {
              if (fileExplorerState.isControlPressed) {
                fileExplorerState.toggleSelection(entity);
              } else {
                if (entity is Directory) {
                  fileExplorerState.toggleExpansion(entity);
                }
                fileExplorerState.toggleSelection(entity);
              }
            },
            text: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            icon: (entity is Directory)
                ? RotatedBox(
                    quarterTurns: isExpanded ? 1 : 0,
                    child: GestureDetector(
                      onTap: () {
                        if (!fileExplorerState.isControlPressed ||
                            !isSelected) {
                          fileExplorerState.toggleExpansion(entity);
                        }
                      },
                      child: Icon(
                        isExpanded ? Icons.chevron_right : Icons.chevron_right,
                        size: 16,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.insert_drive_file,
                      size: 8,
                      color: isSelected
                          ? Colors.white
                          : (isIgnored ? Colors.grey : Colors.black),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _openInVSCode(FileSystemEntity entity) {
    Process.start("code", [entity.path], runInShell: true);
  }

  Future<void> _pasteClipboardContent(
    BuildContext context,
    FileSystemEntity entity,
    FileExplorerState fileExplorerState,
  ) async {
    try {
      final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboard != null && clipboard.text != null) {
        final file = File(entity.path);
        await file.writeAsString(clipboard.text!);
        ShadToaster.of(context).show(
          const ShadToast(
            description: Text('Clipboard content pasted successfully.'),
          ),
        );
      }
    } catch (e) {
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          description: Text('Failed to paste clipboard content.'),
        ),
      );
    }
  }

  Widget _buildFileSystemEntityTree(
    BuildContext context,
    List<FileSystemEntity> entities,
    int level,
  ) {
    final fileExplorerState = context.watch<FileExplorerState>();
    final folders = <Directory>[];
    final files = <File>[];

    for (final entity in entities) {
      if (entity is Directory) {
        folders.add(entity);
      } else if (entity is File) {
        files.add(entity);
      }
    }

    folders
        .sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

    final sortedEntities = [...folders, ...files];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedEntities.map((entity) {
        if (entity is Directory &&
            (fileExplorerState.isExpanded[entity.path] ?? false)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFileSystemEntityTile(
                  context, entity, level, fileExplorerState),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _buildFileSystemEntityTree(
                  context,
                  Directory(entity.path).listSync().toList(),
                  level + 1,
                ),
              ),
            ],
          );
        } else {
          return _buildFileSystemEntityTile(
              context, entity, level, fileExplorerState);
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileExplorerState = context.watch<FileExplorerState>();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fileExplorerState.selectedFolderPath == null)
            ShadButton(
              onPressed: fileExplorerState.openFolder,
              text: const Text('Open Project'),
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Explorer: ${path.basename(fileExplorerState.selectedFolderPath!)}',
                        style: ShadTheme.of(context).textTheme.h4,
                      ),
                      ShadPopover(
                          controller: _popOverController,
                          child: ShadButton.outline(
                            onPressed: () {
                              _popOverController.show();
                            },
                            icon: const Icon(Icons.more_vert),
                          ),
                          popover: (_) => Column(
                                children: [
                                  ShadButton.ghost(
                                    onPressed: () {
                                      _popOverController.hide();
                                      fileExplorerState.openFolder();
                                    },
                                    text: const Text('Change folder'),
                                  ),
                                ],
                              )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildFileSystemEntityTree(
                        context,
                        fileExplorerState.files,
                        0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class CollectionIcon extends StatelessWidget {
  const CollectionIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]),
      child: const Icon(
        Icons.collections,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
