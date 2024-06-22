import 'dart:async';
import 'dart:io';

class DirectoryWatcher {
  late Directory _directory;
  late final StreamController<DirectoryChangeEvent> _controller;
  StreamSubscription<FileSystemEvent>? _directorySubscription;

  DirectoryWatcher() {
    _controller = StreamController.broadcast();
  }

  String? _folderPath;
  set folderPath(String? value) {
    _folderPath = value;
    _directory = Directory(_folderPath ?? '');
    _startWatching();
  }

  Stream<DirectoryChangeEvent> get events => _controller.stream;
  void _startWatching() {
    _directorySubscription?.cancel();
    _directorySubscription = _directory.watch().listen((event) {
      if (event is FileSystemModifyEvent) {
        return;
      }
      _controller.sink.add(DirectoryChangeEvent(
        type: _getChangeType(event),
        path: event.path,
      ));
    });
  }

  ChangeType _getChangeType(FileSystemEvent event) {
    switch (event) {
      case FileSystemCreateEvent():
        return ChangeType.create;
      case FileSystemDeleteEvent():
        return ChangeType.delete;
      case FileSystemModifyEvent():
        return ChangeType.modify;
      case FileSystemMoveEvent():
        return ChangeType.move;
    }
  }

  void dispose() {
    _directorySubscription?.cancel();
    _controller.close();
  }
}

enum ChangeType { create, delete, modify, move }

class DirectoryChangeEvent {
  final ChangeType type;
  final String path;
  DirectoryChangeEvent({
    required this.type,
    required this.path,
  });
}
