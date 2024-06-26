import 'dart:io';

import 'package:buildr_studio/screens/home_screen/file_explorer_state.dart';
import 'package:buildr_studio/screens/home_screen/file_explorer_tree_topbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FileExplorerTree extends StatefulWidget {
  const FileExplorerTree({super.key});

  @override
  State<FileExplorerTree> createState() => _FileExplorerTreeState();
}

class _FileExplorerTreeState extends State<FileExplorerTree> {
  late final FileExplorerState _fileExplorerTreeState;
  final TreeViewController _treeController = TreeViewController();
  ShadThemeData get _theme => ShadTheme.of(context);

  @override
  void initState() {
    super.initState();
    _fileExplorerTreeState = context.read<FileExplorerState>();
    _fileExplorerTreeState.toggleNodeExpansionHandler =
        _treeController.toggleNode;
  }

  Map<Type, GestureRecognizerFactory> _getTapRecognizer(
    TreeViewNode<FileSystemEntity> node,
  ) {
    return <Type, GestureRecognizerFactory>{
      TapGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
        () => TapGestureRecognizer(),
        (TapGestureRecognizer t) {
          t.onTap = () {
            if (_fileExplorerTreeState.isIgnored(node)) return;
            if (_fileExplorerTreeState.isControlPressed) {
              _fileExplorerTreeState.toggleSelection(node);
            } else {
              _treeController.toggleNode(node);
              _fileExplorerTreeState.toggleSelection(node);
            }
          };
          Offset lastTapDownPosition = Offset.zero;
          if (!_fileExplorerTreeState.isIgnored(node)) {
            final isFile = node.content is File;

            t.onSecondaryTapDown = (details) {
              lastTapDownPosition = details.globalPosition;
            };
            t.onSecondaryTap = () {
              final RenderBox overlay =
                  Overlay.of(context).context.findRenderObject() as RenderBox;

              showMenu(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: _theme.radius,
                  side: BorderSide(
                    color: _theme.colorScheme.border,
                    width: 1,
                  ),
                ),
                position: RelativeRect.fromRect(
                    lastTapDownPosition &
                        const Size(40, 40), // smaller rect, the touch area
                    Offset.zero & overlay.size // Bigger rect, the entire screen
                    ),
                items: [
                  if (isFile)
                    PopupMenuItem(
                      onTap: () {
                        _fileExplorerTreeState.pasteClipboardContent(
                            context, node.content);
                      },
                      child: const Text("Paste"),
                    ),
                  if (isFile)
                    PopupMenuItem(
                      onTap: () {
                        _fileExplorerTreeState.openInVSCode(
                            context, node.content);
                      },
                      child: const Text("Open in VSCode"),
                    ),
                  if (isFile)
                    PopupMenuItem(
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                            text: File(node.content.path).readAsStringSync()));
                      },
                      child: const Text("Copy"),
                    ),
                  PopupMenuItem(
                    onTap: () {
                      _fileExplorerTreeState.delete(node.content);
                    },
                    child: const Text("Delete"),
                  ),
                ],
                elevation: 8.0,
              );
            };
          }
        },
      ),
    };
  }

  Widget _treeNodeBuilder(
    BuildContext context,
    TreeViewNode<FileSystemEntity> node,
    toggleAnimationStyle,
  ) {
    final theme = ShadTheme.of(context);
    final isSelected = _fileExplorerTreeState.isSelected(node);
    final isExpanded = node.isExpanded;
    final isIgnored = _fileExplorerTreeState.isIgnored(node);
    return Row(
      key: _fileExplorerTreeState.getNodeKey(node),
      children: [
        (node.content is Directory)
            ? ShadButton.ghost(
                enabled: !isIgnored,
                onPressed: () {
                  _treeController.toggleNode(node);
                },
                size: ShadButtonSize.icon,
                width: 24,
                height: 24,
                hoverBackgroundColor: isSelected
                    ? theme.colorScheme.primaryForeground.withOpacity(0.1)
                    : theme.colorScheme.primary,
                backgroundColor:
                    isSelected ? theme.colorScheme.primary : Colors.transparent,
                foregroundColor:
                    isSelected ? theme.colorScheme.primaryForeground : null,
                hoverForegroundColor: isSelected
                    ? theme.colorScheme.primaryForeground
                    : theme.colorScheme.primaryForeground,
                icon: RotatedBox(
                  quarterTurns: isExpanded ? 1 : 0,
                  child: Icon(
                    isExpanded ? Icons.chevron_right : Icons.chevron_right,
                    size: 16,
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 12, right: 10),
                child: Icon(
                  Icons.insert_drive_file,
                  size: 12,
                  color:
                      isSelected ? theme.colorScheme.primaryForeground : null,
                ),
              ),
        const SizedBox(width: 2),
        Text(
          _fileExplorerTreeState.getDisplayName(
            node.content.path,
          ),
          style: theme.textTheme.small.copyWith(
            fontWeight: FontWeight.normal,
            color: isIgnored
                ? theme.colorScheme.foreground.withOpacity(0.2)
                : isSelected
                    ? theme.colorScheme.primaryForeground
                    : theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  TreeRow _treeRowBuilder(TreeViewNode<FileSystemEntity> node) {
    final isSelected = _fileExplorerTreeState.isSelected(node);
    final isIgnored = _fileExplorerTreeState.isIgnored(node);
    return TreeView.defaultTreeRowBuilder(node).copyWith(
      extent: const FixedSpanExtent(32),
      cursor:
          isIgnored ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) {
        _fileExplorerTreeState.onHover(node);
      },
      onExit: (_) {
        _fileExplorerTreeState.onHoverExit();
      },
      recognizerFactories: _getTapRecognizer(node),
      backgroundDecoration: TreeRowDecoration(
        borderRadius: _theme.radius,
        color: isSelected ? _theme.colorScheme.primary : null,
      ),
      foregroundDecoration: TreeRowDecoration(
        borderRadius: _theme.radius,
        color: _fileExplorerTreeState.hoveredNode == node
            ? isSelected
                ? _theme.colorScheme.primaryForeground.withOpacity(0.1)
                : _theme.colorScheme.primary.withOpacity(0.1)
            : null,
      ),
    );
  }

  Widget _getTree() {
    return Scrollbar(
      controller: _fileExplorerTreeState.horizontalController,
      thumbVisibility: true,
      child: Scrollbar(
        controller: _fileExplorerTreeState.verticalController,
        thumbVisibility: true,
        child: Draggable<bool>(
          data: true,
          dragAnchorStrategy: pointerDragAnchorStrategy,
          feedback: const CollectionIcon(),
          onDragStarted: () {},
          onDragUpdate: (details) {
            _fileExplorerTreeState.onDragStarted(details.globalPosition);
          },
          onDraggableCanceled: (_, __) {
            _fileExplorerTreeState.onDragDone();
          },
          onDragEnd: (_) {
            _fileExplorerTreeState.onDragDone();
          },
          child: TreeView<FileSystemEntity>(
            controller: _treeController,
            verticalDetails: ScrollableDetails.vertical(
              controller: _fileExplorerTreeState.verticalController,
            ),
            horizontalDetails: ScrollableDetails.horizontal(
              controller: _fileExplorerTreeState.horizontalController,
            ),
            tree: _fileExplorerTreeState.tree,
            onNodeToggle: (TreeViewNode<FileSystemEntity> node) {},
            treeNodeBuilder: _treeNodeBuilder,
            treeRowBuilder: _treeRowBuilder,
            indentation: TreeViewIndentationType.custom(16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileExplorerTreeState = context.watch<FileExplorerState>();

    Widget child;

    if (_fileExplorerTreeState.isTreeLoading) {
      child = const Center(child: CircularProgressIndicator());
    } else if (_fileExplorerTreeState.selectedFolderPath == null ||
        _fileExplorerTreeState.tree.isEmpty) {
      child = const SizedBox();
    } else {
      child = Scaffold(
        body: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: _getTree(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fileExplorerTreeState.selectedFolderPath == null)
            ShadButton(
              onPressed: fileExplorerTreeState.openFolder,
              text: const Text('Open Project'),
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FileExplorerTreeTopbar(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: child,
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
