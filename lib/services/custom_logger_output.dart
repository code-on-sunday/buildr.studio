import 'dart:async';
import 'dart:io';

import 'package:buildr_studio/env/env.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CustomLoggerOutput extends LogOutput {
  final LogMemoryStorage _logMemoryStorage;

  CustomLoggerOutput({
    LogMemoryStorage? logMemoryStorage,
  }) : _logMemoryStorage = logMemoryStorage ?? LogMemoryStorage();

  @override
  void output(OutputEvent event) {
    if (kDebugMode) {
      for (var line in event.lines) {
        print(line);
      }
    }
    _logMemoryStorage.addLog(event);
  }
}

class LogMemoryStorage {
  final List<OutputEvent> _logs = [];

  void addLog(OutputEvent log) {
    _logs.add(log);
  }

  List<OutputEvent> getLogs() {
    return _logs;
  }

  void removeTopLogs(int count) {
    _logs.removeRange(0, count);
  }
}

class LogDumpScheduler {
  static const _dumpInterval = Duration(seconds: 3);
  static const _maxLogFileSize = 10 * 1024 * 1024; // 10 MB
  static const _maxLogFiles = 3;

  LogDumpScheduler({
    required LogMemoryStorage logMemoryStorage,
  }) : _logMemoryStorage = logMemoryStorage;

  final LogMemoryStorage _logMemoryStorage;
  Timer? _timer;
  int _logFileIndex = 0;

  void start() {
    _timer = Timer.periodic(_dumpInterval, (_) {
      _dumpLogs();
    });
  }

  void stop() {
    _timer?.cancel();
  }

  Future<void> _dumpLogs() async {
    final logEvents = _logMemoryStorage.getLogs();
    var output = "";
    for (var event in logEvents) {
      for (var line in event.lines) {
        output += '$line\n';
      }
    }
    if (output.isEmpty) return;
    if (output.length < 16) {
      output += "Dumping logs at ${DateTime.now()}\n";
    }
    final encryptedLogs = _encryptLogs(output);
    var logFile = await _getLogFile();
    try {
      if (await logFile.length() >= _maxLogFileSize) {
        _logFileIndex++;
        logFile = await _getLogFile();
      }
      await logFile.writeAsString(encryptedLogs, mode: FileMode.append);
    } catch (e) {
      print('Error writing logs to file: $e');
    }

    if (kDebugMode) {
      await _writeDecryptedLogs();
    }

    await _removeOldLogFiles();
    _logMemoryStorage.removeTopLogs(logEvents.length);
  }

  Future<void> _removeOldLogFiles() async {
    final directory = await getApplicationSupportDirectory();
    final logFiles =
        await Directory(join(directory.path, 'logs')).list().toList();
    if (logFiles.length > _maxLogFiles) {
      logFiles.sort((a, b) => a.path.compareTo(b.path));
      for (int i = 0; i < logFiles.length - _maxLogFiles; i++) {
        try {
          await logFiles[i].delete();
        } catch (e) {
          print('Error deleting log file: $e');
        }
      }
    }
  }

  Future<void> _writeDecryptedLogs() async {
    try {
      final encryptedLogFile = await _getLogFile();
      final decryptedLogFile = await _getDecryptedLogFile();
      final decryptedLogs = _decryptLogs(encryptedLogFile.readAsStringSync());
      await decryptedLogFile.writeAsString(decryptedLogs, mode: FileMode.write);
    } catch (e) {
      print('Error writing decrypted logs: $e');
    }
  }

  String _encryptLogs(String output) {
    final key = Key.fromUtf8(Env.logAesKey);
    final iv = IV.fromUtf8(Env.logAesNonce);
    final encryptedLogs = _encryptAES(output, key, iv);
    return encryptedLogs;
  }

  String _decryptLogs(String encryptedLogs) {
    final key = Key.fromUtf8(Env.logAesKey);
    final iv = IV.fromUtf8(Env.logAesNonce);
    final decryptedLogs = _decryptAES(encryptedLogs, key, iv);
    return decryptedLogs;
  }

  String _encryptAES(String data, Key key, IV iv) {
    final cipher = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = cipher.encrypt(data, iv: iv);
    return encrypted.base16;
  }

  String _decryptAES(String encryptedData, Key key, IV iv) {
    final cipher = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted =
        cipher.decrypt(Encrypted.fromBase16(encryptedData), iv: iv);
    return decrypted;
  }

  Future<File> _getLogFile() async {
    final directory = await getApplicationSupportDirectory();
    final logFile =
        File(join(directory.path, 'logs', 'logs_$_logFileIndex.txt'));
    if (!logFile.existsSync()) {
      logFile.createSync(recursive: true);
    }
    return logFile;
  }

  Future<File> _getDecryptedLogFile() async {
    final directory = await getApplicationSupportDirectory();
    final decryptedLogFile =
        File(join(directory.path, 'logs', 'logs_$_logFileIndex.decrypted.txt'));
    if (!decryptedLogFile.existsSync()) {
      decryptedLogFile.createSync(recursive: true);
    }
    return decryptedLogFile;
  }
}
