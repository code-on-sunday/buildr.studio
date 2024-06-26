import 'dart:async';
import 'dart:isolate';

import 'package:buildr_studio/screens/home_screen/terminal_pty_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:xterm/xterm.dart';

class TerminalPanel extends StatefulWidget {
  const TerminalPanel({super.key, required this.workingDirectory});

  final String? workingDirectory;

  @override
  // ignore: library_private_types_in_public_api
  _TerminalPanelState createState() => _TerminalPanelState();
}

class _TerminalPanelState extends State<TerminalPanel> {
  final _logger = GetIt.I.get<Logger>();

  final terminal = Terminal(
    maxLines: 10000,
  );

  final terminalController = TerminalController();

  late SendPort _ptyIsolateSendPort;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.endOfFrame.then(
      (_) {
        if (mounted) {
          _startPty();
        }
      },
    );
  }

  @override
  void dispose() {
    _killPty();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TerminalPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workingDirectory != widget.workingDirectory) {
      _killPty();
      _startPty();
    }
  }

  void _startPty() async {
    ReceivePort receivePort = ReceivePort();
    Completer<void> isolateReady = Completer<void>();

    receivePort.listen((message) {
      switch (message) {
        case SendPort():
          _ptyIsolateSendPort = message;
          isolateReady.complete();
          break;
        case ['output', String data]:
          terminal.write(data);
          break;
        case ['log', String message]:
          _logger.d(message);
          break;
        case ['error', String message]:
          _logger.e(message);
          showShadDialog(
            context: context,
            builder: (_) => ShadDialog.alert(
              title: const Text('Error while running terminal'),
              content: Text(message),
            ),
          );
          break;
        case ['exit', int code]:
          terminal.write('the process exited with exit code $code');
          break;
        default:
      }
    });
    Isolate.spawn(TerminalPtyHandler.run, receivePort.sendPort);

    await isolateReady.future;
    _ptyIsolateSendPort.send(['start', widget.workingDirectory]);

    terminal.onOutput = (data) {
      _write(data);
    };
    terminal.onResize = (w, h, pw, ph) {
      _resize(h, w);
    };
  }

  void _killPty() {
    _ptyIsolateSendPort.send(['kill']);
  }

  void _write(String data) {
    _ptyIsolateSendPort.send(['write', data]);
  }

  void _resize(int columns, int rows) {
    _ptyIsolateSendPort.send(['resize', columns, rows]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadTheme.of(context).colorScheme.secondary,
      body: SafeArea(
        child: TerminalView(
          terminal,
          controller: terminalController,
          autofocus: true,
          backgroundOpacity: 0,
          onSecondaryTapDown: (details, offset) async {
            final selection = terminalController.selection;
            if (selection != null) {
              final text = terminal.buffer.getText(selection);
              terminalController.clearSelection();
              await Clipboard.setData(ClipboardData(text: text));
            } else {
              final data = await Clipboard.getData('text/plain');
              final text = data?.text;
              if (text != null) {
                terminal.paste(text);
              }
            }
          },
        ),
      ),
    );
  }
}
