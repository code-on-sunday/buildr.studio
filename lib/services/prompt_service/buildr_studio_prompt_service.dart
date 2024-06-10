import 'dart:async';

import 'package:buildr_studio/env/env.dart';
import 'package:buildr_studio/services/prompt_service/prompt_service.dart';
import 'package:socket_io_client/socket_io_client.dart';

class BuildrStudioPromptService implements PromptService {
  late final Socket _socket =
      io(Env.apiBaseUrl, OptionBuilder().setTransports(['websocket']).build());
  final _responseController = StreamController<String>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _endController = StreamController<void>.broadcast();
  bool _streaming = false;

  @override
  void connect() {
    print('Connecting to server');

    if (_socket.connected) {
      print('Already connected to server');
      return;
    }
    _socket.onConnect((_) {
      print('Connected to server');
    });

    _socket.onConnectError((data) => print('Connect error: $data'));

    _socket.onReconnect((data) => print('Reconnected to server'));

    _socket.onReconnectError((data) => print('Reconnect error: $data'));

    _socket.onDisconnect((_) {
      _streaming = false;
      _endController.sink.add(null);
      print('Disconnected from server');
    });

    print('Listening to server events');

    _socket.on('chunk', (data) {
      _streaming = true;
      _responseController.sink.add(data);
    });

    _socket.on('end', (_) {
      print('Received end event');
      _streaming = false;
      _endController.sink.add(null);
    });

    _socket.on('error', (error) {
      print('Received error: $error');
      _streaming = false;
      _errorController.sink.add(error.toString());
    });
  }

  @override
  void sendPrompt(String prompt) {
    if (_streaming) {
      _socket.emit('cancel');
    }
    _socket.emit('prompt', prompt);
  }

  @override
  Stream<String> get responseStream => _responseController.stream;
  @override
  Stream<String> get errorStream => _errorController.stream;
  @override
  Stream<void> get endStream => _endController.stream;

  void dispose() {
    _responseController.close();
    _errorController.close();
    _endController.close();
    _socket.disconnect();
  }
}
