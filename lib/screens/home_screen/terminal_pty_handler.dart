import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_pty/flutter_pty.dart';

class TerminalPtyHandler {
  static void run(SendPort sendPort) {
    late Pty pty;

    bool isPwshAvailable() {
      try {
        // Check if pwsh is available by running the command and checking the exit code
        Process.runSync('pwsh', ['-c', 'exit 0']);
        return true;
      } catch (e) {
        return false;
      }
    }

    void startPty(String? workingDirectory) {
      try {
        if (Platform.isMacOS) {
          pty = Pty.start(
            Platform.environment['SHELL'] ?? 'bash',
            columns: 80,
            rows: 24,
          );
        } else {
          // Check if pwsh is available
          if (isPwshAvailable()) {
            sendPort.send(
                ['log', 'pwsh is available, using it instead of cmd.exe']);
            pty = Pty.start(
              'cmd.exe',
              arguments: [
                "/k",
                "pwsh",
                "-ExecutionPolicy",
                "Bypass",
              ],
              environment: {...Platform.environment},
              columns: 80,
              rows: 24,
            );
          } else {
            // Fall back to cmd.exe
            sendPort.send(
                ['log', 'pwsh is not available, falling back to cmd.exe']);
            pty = Pty.start(
              'cmd.exe',
              environment: {...Platform.environment},
              columns: 80,
              rows: 24,
            );
          }
        }

        if (workingDirectory != null) {
          pty.write(const Utf8Encoder()
              .convert('cd "$workingDirectory"${Platform.lineTerminator}'));
        }

        pty.output
            .cast<List<int>>()
            .transform(const Utf8Decoder())
            .listen((data) {
          sendPort.send(['output', data]);
        });

        pty.exitCode.then((code) {
          sendPort.send(['exit', code]);
        });
      } catch (e) {
        sendPort.send(['error', e.toString()]);
      }
    }

    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      switch (message) {
        case ['start', String dir]:
          startPty(dir);
          break;
        case ['write', String data]:
          pty.write(const Utf8Encoder().convert(data));
          break;
        case ['resize', int columns, int rows]:
          pty.resize(columns, rows);
          break;
        case ['kill']:
          pty.kill();
          break;
        default:
      }
    });
  }
}
