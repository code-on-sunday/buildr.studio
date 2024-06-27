import 'dart:async';
import 'dart:io';

class DirectoryWatcher {
  late Directory _directory;
  late final StreamController<FileSystemEvent> _controller;
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

  Stream<FileSystemEvent> get events => _controller.stream;
  void _startWatching() {
    _directorySubscription?.cancel();
    _directorySubscription = _directory.watch(recursive: true).listen((event) {
      if (event is FileSystemModifyEvent) {
        return;
      }
      _controller.add(event);
    });
  }

  Future<void> dispose() async {
    await _directorySubscription?.cancel();
    await _controller.close();
  }
}
