import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:buildr_studio/repositories/user_preferences_repository.dart';
import 'package:buildr_studio/utils/directory_watcher.dart';
import 'package:buildr_studio/utils/file_utils.dart';
import 'package:buildr_studio/utils/ignore.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:process_run/process_run.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FileExplorerState extends ChangeNotifier {
  final _logger = GetIt.I.get<Logger>();

  final UserPreferencesRepository _userPreferencesRepository;
  final FileUtils _fileUtils;
  DirectoryWatcher? _directoryWatcher;

  bool _isControlPressed = false;
  String? _selectedFolderPath;
  List<TreeViewNode<FileSystemEntity>> _tree = [];
  Map<String, TreeViewNode<FileSystemEntity>> _allNodes = {};
  Map<String, GlobalKey> _nodeKeys = {};
  Set<String> _ignoredNodes = {};
  bool _isTreeLoading = false;
  final _selectedNodes = <TreeViewNode<FileSystemEntity>>{};
  TreeViewNode<FileSystemEntity>? _hoveredNode;
  bool _dragStarted = false;
  StreamSubscription<FileSystemEvent>? _directorySubscription;

  final popOverController = ShadPopoverController();
  final ScrollController horizontalController = ScrollController();
  final ScrollController verticalController = ScrollController();
  void Function(TreeViewNode<FileSystemEntity> node)?
      toggleNodeExpansionHandler;

  FileExplorerState({
    required UserPreferencesRepository userPreferencesRepository,
    required FileUtils fileUtils,
  })  : _userPreferencesRepository = userPreferencesRepository,
        _fileUtils = fileUtils {
    ServicesBinding.instance.keyboard.addHandler(
      onKeyEvent,
    );
    loadStoredLastWorkingDir();
  }

  @override
  Future<void> dispose() async {
    ServicesBinding.instance.keyboard.removeHandler(
      onKeyEvent,
    );
    await _directoryWatcher?.dispose();
    popOverController.dispose();
    verticalController.dispose();
    horizontalController.dispose();
    super.dispose();
  }

  List<TreeViewNode<FileSystemEntity>> get tree => _tree;
  bool get isTreeLoading => _isTreeLoading;
  TreeViewNode<FileSystemEntity>? get hoveredNode => _hoveredNode;

  bool get isControlPressed => _isControlPressed;
  String? get selectedFolderPath => _selectedFolderPath;

  List<String> get selectedPaths {
    final selectedPaths = <String>[];
    for (final node in _selectedNodes) {
      if (!_isAncenstorSelected(node)) {
        selectedPaths.add(node.content.path);
      }
    }
    return selectedPaths;
  }

  bool isSelected(TreeViewNode<FileSystemEntity> node) =>
      _selectedNodes.contains(node);

  bool isIgnored(TreeViewNode<FileSystemEntity> node) =>
      _ignoredNodes.contains(node.content.path);

  bool isPathIgnored(String path) {
    return _ignoredNodes.contains(path);
  }

  GlobalKey getNodeKey(TreeViewNode<FileSystemEntity> node) =>
      _nodeKeys[node.content.path]!;

  TreeViewNode<FileSystemEntity>? findNodeAtOffset(Offset offset) {
    for (final key in _nodeKeys.keys) {
      final renderBox =
          _nodeKeys[key]!.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) continue;
      final nodeOffset = renderBox.localToGlobal(Offset.zero);
      final nodeSize = renderBox.size;
      if (offset.dy >= nodeOffset.dy &&
          offset.dy <= nodeOffset.dy + nodeSize.height) {
        return _allNodes[key];
      }
    }
    return null;
  }

  void onDragStarted(Offset offset) {
    if (_dragStarted) return;
    _dragStarted = true;
    final nodeUnderDrag = findNodeAtOffset(offset);
    if (nodeUnderDrag == null) return;
    if (isIgnored(nodeUnderDrag)) return;
    if (isSelected(nodeUnderDrag)) return;
    toggleSelection(nodeUnderDrag);
  }

  void onDragDone() {
    _dragStarted = false;
  }

  Future<void> openFolder() async {
    final directory = await getApplicationDocumentsDirectory();
    final selectedDirectory = await FilePicker.platform.getDirectoryPath(
      initialDirectory: directory.path,
    );
    if (selectedDirectory == null) return;
    await _inflateSelectedWorkingDir(selectedDirectory);
    _userPreferencesRepository.setLastWorkingDir(selectedDirectory);
  }

  Future<void> createNewProject(
      Future<String?> Function() requestProjectName) async {
    String? newFolderPath;

    // Open directory picker to select the parent folder
    final directory = await getApplicationDocumentsDirectory();
    final selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select parent folder for new project',
      initialDirectory: _selectedFolderPath ?? directory.path,
    );

    if (selectedDirectory == null) return;

    final projectName = await requestProjectName();

    if (projectName == null) return;

    // Create a new folder in the selected parent directory
    newFolderPath = path.join(selectedDirectory, projectName);

    try {
      await _directoryWatcher?.dispose();
      await _directorySubscription?.cancel();
      Directory(newFolderPath).createSync();
      await _inflateSelectedWorkingDir(newFolderPath);
      _userPreferencesRepository.setLastWorkingDir(newFolderPath);
    } catch (e, st) {
      _logger.e('Error creating new folder', error: e, stackTrace: st);
    }
  }

  void createNewFile(String fileName) {
    final lastSelectedNode = _selectedNodes.lastOrNull;
    String? parentDir;
    if (lastSelectedNode != null) {
      parentDir = switch (lastSelectedNode.content) {
        File() => path.dirname(lastSelectedNode.content.path),
        Directory() => lastSelectedNode.content.path,
        _ => null,
      };
    }
    parentDir ??= _selectedFolderPath!;
    final newFilePath = path.join(parentDir, fileName);
    File(newFilePath).createSync();
  }

  void createNewFolder(String folderName) {
    final lastSelectedNode = _selectedNodes.lastOrNull;
    String? parentDir;
    if (lastSelectedNode != null) {
      parentDir = switch (lastSelectedNode.content) {
        File() => path.dirname(lastSelectedNode.content.path),
        Directory() => lastSelectedNode.content.path,
        _ => null,
      };
    }
    parentDir ??= _selectedFolderPath!;
    final newFolderPath = path.join(parentDir, folderName);
    Directory(newFolderPath).createSync();
  }

  void delete(FileSystemEntity entity) {
    if (entity is Directory) {
      entity.deleteSync(recursive: true);
    } else {
      entity.deleteSync();
    }
    _selectedNodes.clear();
  }

  void openInVSCode(BuildContext context, FileSystemEntity entity) async {
    try {
      final vscodePath = await which('code');
      if (vscodePath == null) {
        throw Exception('VSCode not found on the system.');
      }
      await Process.run(vscodePath, [entity.path]);
    } catch (e) {
      _logger.e('Error opening file in VSCode: $e');
      showShadDialog(
        context: context,
        builder: (_) => ShadDialog.alert(
          title: const Text('Error opening file in VSCode'),
          description: Text('$e'),
        ),
      );
    }
  }

  Future<void> pasteClipboardContent(
    BuildContext context,
    FileSystemEntity entity,
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

  String getDisplayName(String path) {
    return _fileUtils.getDisplayFileName(
      selectedFolderPath,
      path,
    );
  }

  void loadStoredLastWorkingDir() async {
    final lastWorkingDir = _userPreferencesRepository.getLastWorkingDir();
    if (lastWorkingDir == null) return;
    if (!Directory(lastWorkingDir).existsSync()) {
      _userPreferencesRepository.clearLastWorkingDir();
      return;
    }
    await _inflateSelectedWorkingDir(lastWorkingDir);
  }

  bool _isAncenstorSelected(TreeViewNode<FileSystemEntity> node) {
    final parent = node.parent;
    if (parent == null) return false;
    if (_selectedNodes.contains(parent)) return true;
    return _isAncenstorSelected(parent);
  }

  Future<void> _inflateSelectedWorkingDir(String path) async {
    _selectedNodes.clear();
    _ignoredNodes.clear();
    _tree.clear();
    _allNodes.clear();
    _nodeKeys.clear();
    _hoveredNode = null;
    _selectedFolderPath = path;
    _directoryWatcher = DirectoryWatcher();
    _directorySubscription = _directoryWatcher!.events.listen(_updateTree);
    Future.delayed(
      const Duration(seconds: 1),
      () {
        _directoryWatcher!.folderPath = path;
      },
    );
    await _buildTree();
    notifyListeners();
  }

  Future<void> _buildTree({
    bool showLoading = true,
  }) async {
    if (showLoading) {
      _isTreeLoading = true;
      notifyListeners();
    }

    try {
      final (nodes, ignoredNodes, allNodes) = await compute(
          (rootDir) => _buildTreeNodes((Directory(rootDir), Queue.from([]))),
          _selectedFolderPath!);
      _tree = nodes;
      _ignoredNodes = ignoredNodes;
      _allNodes = Map.fromEntries(
          allNodes.map((node) => MapEntry(node.content.path, node)));
      _nodeKeys = Map.fromEntries(
        allNodes.map((node) => MapEntry(node.content.path, GlobalKey())),
      );
    } catch (e, st) {
      _logger.e('Error loading tree', error: e, stackTrace: st);
    }
    _isTreeLoading = false;

    notifyListeners();
  }

  Future<void> _buildChildrenTree(TreeViewNode<FileSystemEntity> node) async {
    if (node.content is Directory) {
      final (childNodes, childIgnoredNodes, allDescendantNodes) = await compute(
        (rootDir) => _buildTreeNodes((rootDir, Queue.from([]))),
        Directory(node.content.path),
      );
      node.children.addAll(childNodes);
      _ignoredNodes.addAll(childIgnoredNodes);
      _allNodes.addAll(Map.fromEntries(
        allDescendantNodes.map((n) => MapEntry(n.content.path, n)),
      ));
      _nodeKeys.addAll(Map.fromEntries(
        allDescendantNodes.map((n) => MapEntry(n.content.path, GlobalKey())),
      ));
    }
  }

  Future<void> _updateTree(FileSystemEvent event) async {
    switch (event) {
      case FileSystemCreateEvent():
        await _handleCreate(event.path);
        break;
      case FileSystemDeleteEvent():
        await _handleDelete(event.path);
        break;
      case FileSystemMoveEvent():
        await _handleMove(event.path, event.destination);
        break;
      default:
    }
    notifyListeners();
  }

  Future<void> _handleCreate(String newPath) async {
    final newNode = switch (FileSystemEntity.typeSync(newPath)) {
      FileSystemEntityType.directory =>
        TreeViewNode<FileSystemEntity>(Directory(newPath)),
      FileSystemEntityType.file =>
        TreeViewNode<FileSystemEntity>(File(newPath)),
      _ => null,
    };

    if (newNode == null) return;

    if (_allNodes.containsKey(newPath)) return;

    for (final ignoredNode in _ignoredNodes) {
      if (path.isWithin(ignoredNode, newPath)) return;
    }

    // Add the new node to the tree in the proper position
    _allNodes[newPath] = newNode;
    _nodeKeys[newPath] = GlobalKey();
    final parentDir = path.dirname(newPath);
    final parentNode = _allNodes[parentDir];
    if (parentNode != null) {
      parentNode.children
          .insert(_findInsertIndex(parentNode.children, newNode), newNode);
    } else {
      _tree.insert(_findInsertIndex(_tree, newNode), newNode);
    }

    // Build the children tree for the new node
    await _buildChildrenTree(newNode);
  }

  Future<void> _handleMove(String oldPath, String? newPath) async {
    if (newPath == null) {
      await _buildTree();
      return;
    }
    final movedNode = _allNodes[oldPath];
    if (movedNode == null) return;

    bool isSelectedOldNode = false;

    bool isIgnoredOldPath = false;
    for (final ignoredNode in _ignoredNodes) {
      if (path.isWithin(ignoredNode, oldPath)) {
        isIgnoredOldPath = true;
        break;
      }
    }
    if (!isIgnoredOldPath) {
      // Remove the moved node from the old location
      _allNodes.remove(oldPath);
      _nodeKeys.remove(oldPath);
      final oldParentNode = movedNode.parent;
      if (oldParentNode != null) {
        oldParentNode.children.remove(movedNode);
      } else {
        _tree.remove(movedNode);
      }

      isSelectedOldNode = _selectedNodes.contains(movedNode);
      if (isSelectedOldNode) {
        _selectedNodes.remove(movedNode);
      }
    }

    bool isIgnoredNewPath = false;
    for (final ignoredNode in _ignoredNodes) {
      if (path.isWithin(ignoredNode, newPath)) {
        isIgnoredNewPath = true;
        break;
      }
    }
    if (!isIgnoredNewPath) {
      // Add the moved node to the new location in the proper position
      final newNode = TreeViewNode<FileSystemEntity>(
        File(newPath),
        children: movedNode.children,
      );
      if (_allNodes.containsKey(newPath)) return;
      _allNodes[newPath] = newNode;
      _nodeKeys[newPath] = GlobalKey();
      final newParentDir = path.dirname(newPath);
      final newParentNode = _allNodes[newParentDir];
      if (newParentNode != null) {
        newParentNode.children
            .insert(_findInsertIndex(newParentNode.children, newNode), newNode);
      } else {
        _tree.insert(_findInsertIndex(_tree, newNode), newNode);
      }

      if (isSelectedOldNode) {
        _selectedNodes.add(newNode);
      }
    }
  }

  Future<void> _handleDelete(String deletedPath) async {
    final deletedNode = _allNodes[deletedPath];
    if (deletedNode == null) return;
    // Remove the deleted node from the tree
    final parentNode = deletedNode.parent;
    if (parentNode != null) {
      parentNode.children.remove(deletedNode);
    } else {
      _tree.remove(deletedNode);
    }
    _allNodes.remove(deletedPath);
    _nodeKeys.remove(deletedPath);
    _selectedNodes.remove(deletedNode);
  }

  int _findInsertIndex(List<TreeViewNode<FileSystemEntity>> siblingNodes,
      TreeViewNode<FileSystemEntity> newNode) {
    int startingIndex = 0;
    int insertIndex = siblingNodes.length;

    if (newNode.content is File) {
      final firstFileIndex = siblingNodes.indexWhere(
        (node) => node.content is File,
      );
      if (firstFileIndex == -1) {
        startingIndex = siblingNodes.length;
      } else {
        startingIndex = firstFileIndex;
      }
    }

    for (int i = startingIndex; i < siblingNodes.length; i++) {
      final childNode = siblingNodes[i];
      if (childNode.content.path
              .toLowerCase()
              .compareTo(newNode.content.path.toLowerCase()) >
          0) {
        insertIndex = i;
        break;
      }
    }

    return insertIndex;
  }

  void onHover(TreeViewNode<FileSystemEntity> node) {
    _hoveredNode = node;
    notifyListeners();
  }

  void onHoverExit() {
    _hoveredNode = null;
    notifyListeners();
  }

  void toggleSelection(TreeViewNode<FileSystemEntity> node) {
    if (_isControlPressed) {
      if (_selectedNodes.contains(node)) {
        _selectedNodes.remove(node);
      } else {
        _selectedNodes.add(node);
      }
    } else {
      _selectedNodes.clear();
      _selectedNodes.add(node);
    }
    notifyListeners();
  }

  bool onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
          event.logicalKey == LogicalKeyboardKey.controlRight) {
        _isControlPressed = true;
        notifyListeners();
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
          event.logicalKey == LogicalKeyboardKey.controlRight) {
        _isControlPressed = false;
        notifyListeners();
      }
    }
    return false;
  }
}

(
  List<TreeViewNode<FileSystemEntity>> nodes,
  Set<String> ignoredNodes,
  Set<TreeViewNode<FileSystemEntity>> allNodes,
) _buildTreeNodes(
    (
      Directory directory,
      Queue<(Ignore ignore, String posixDirPath)> ignores
    ) args) {
  final List<TreeViewNode<FileSystemEntity>> nodes = [];
  final Set<String> ignoredNodes = {};
  final Set<TreeViewNode<FileSystemEntity>> allNodes = {};
  final (directory, ignores) = args;
  final posixContext = path.Context(style: path.Style.posix);

  bool addedGitIgnore = false;
  final gitignoreFile = directory.listSync().firstWhereOrNull(
      (e) => e is File && path.basename(e.path) == '.gitignore');
  if (gitignoreFile != null) {
    addedGitIgnore = true;
    var gitIgnoreContent = File(gitignoreFile.path).readAsLinesSync();
    final ignore = Ignore()..add(gitIgnoreContent);
    ignore.addPattern('.git');
    ignores.add((ignore, posixContext.fromUri(directory.uri)));
  }

  for (final entity in directory.listSync()) {
    final tempIgnores = ignores.toList();
    bool isIgnored = false;

    while (tempIgnores.isNotEmpty) {
      final lastIgnore = tempIgnores.removeLast();
      final (ignore, posixDirPath) = lastIgnore;
      final posixEntityPath = posixContext.fromUri(entity.uri);
      var posixRelativePath =
          posixContext.relative(posixEntityPath, from: posixDirPath);
      if (entity is Directory) {
        posixRelativePath += posixContext.separator;
      }
      isIgnored = ignore.ignores(posixRelativePath);
      if (isIgnored) {
        break;
      }
    }

    if (isIgnored) {
      ignoredNodes.add(entity.path);
      final node = TreeViewNode<FileSystemEntity>(entity);
      nodes.add(node);
      allNodes.add(node);
    } else {
      if (entity is Directory) {
        final (childNodes, childIgnoredNodes, allDescendantNodes) =
            _buildTreeNodes((entity, ignores));
        final node = TreeViewNode<FileSystemEntity>(
          entity,
          children: childNodes,
        );
        nodes.add(node);
        ignoredNodes.addAll(childIgnoredNodes);
        allNodes.add(node);
        allNodes.addAll(allDescendantNodes);
      } else if (entity is File) {
        final node = TreeViewNode<FileSystemEntity>(entity);
        nodes.add(node);
        allNodes.add(node);
      }
    }
  }
  final folderNodes = nodes.where((node) => node.content is Directory).toList();
  final fileNodes = nodes.where((node) => node.content is File).toList();

  folderNodes.sort((a, b) =>
      a.content.path.toLowerCase().compareTo(b.content.path.toLowerCase()));
  fileNodes.sort((a, b) =>
      a.content.path.toLowerCase().compareTo(b.content.path.toLowerCase()));
  nodes.clear();
  nodes.addAll([...folderNodes, ...fileNodes]);

  if (ignores.isNotEmpty && addedGitIgnore) {
    ignores.removeLast();
  }
  return (nodes, ignoredNodes, allNodes);
}
