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
import 'package:shadcn_ui/shadcn_ui.dart';

class FileExplorerState extends ChangeNotifier {
  final _logger = GetIt.I.get<Logger>();

  final UserPreferencesRepository _userPreferencesRepository;
  final FileUtils _fileUtils;
  final DirectoryWatcher _directoryWatcher = DirectoryWatcher();

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

  final popOverController = ShadPopoverController();
  final ScrollController horizontalController = ScrollController();
  final ScrollController verticalController = ScrollController();

  FileExplorerState({
    required UserPreferencesRepository userPreferencesRepository,
    required FileUtils fileUtils,
  })  : _userPreferencesRepository = userPreferencesRepository,
        _fileUtils = fileUtils {
    ServicesBinding.instance.keyboard.addHandler(
      onKeyEvent,
    );
    _directoryWatcher.events.listen(_onContentChanged);
    _loadStoredLastWorkingDir();
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(
      onKeyEvent,
    );
    _directoryWatcher.dispose();
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

  bool isPathIgnored(String path) => _ignoredNodes.contains(path);

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

  void openInVSCode(FileSystemEntity entity) {
    Process.start("code", [entity.path], runInShell: true);
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

  void _loadStoredLastWorkingDir() async {
    final lastWorkingDir = _userPreferencesRepository.getLastWorkingDir();
    if (lastWorkingDir == null) return;
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
    _directoryWatcher.folderPath = path;
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

  void _onContentChanged(DirectoryChangeEvent event) async {
    await _buildTree(showLoading: false);
    notifyListeners();
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
    ignores.add((
      Ignore()..add(File(gitignoreFile.path).readAsLinesSync()),
      posixContext.fromUri(directory.uri)
    ));
  }

  for (final entity in directory.listSync()) {
    final tempIgnores = ignores.toList();
    bool isIgnored = false;

    if (entity is Directory && path.basename(entity.path) == '.git') {
      isIgnored = true;
    } else {
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
    }

    if (isIgnored) {
      ignoredNodes.add(entity.path);
    }

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
