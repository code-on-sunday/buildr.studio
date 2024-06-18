import 'dart:async';
import 'dart:io';

import 'package:buildr_studio/env/env.dart';
import 'package:buildr_studio/models/prompt_service_connection_status.dart';
import 'package:buildr_studio/services/prompt_service/authenticated_buildr_studio_request_builder.dart';
import 'package:buildr_studio/services/prompt_service/prompt_service.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart';

class BuildrStudioPromptService implements PromptService {
  BuildrStudioPromptService(
      {required AuthenticatedBuildrStudioRequestBuilder requestBuilder})
      : _requestBuilder = requestBuilder;

  final _logger = GetIt.I.get<Logger>();
  final AuthenticatedBuildrStudioRequestBuilder _requestBuilder;
  late final Socket _socket =
      io(Env.apiBaseUrl, OptionBuilder().setTransports(['websocket']).build());
  final _responseController = StreamController<String>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _endController = StreamController<void>.broadcast();
  final _connectionStatusController =
      StreamController<PromptServiceConnectionStatus>.broadcast();
  bool _streaming = false;

  final List<dynamic Function()> _connectionStatusListeners = [];

  @override
  bool get connected => _socket.connected;

  @override
  void connect() {
    _logger.d('Connecting to server');

    _connectionStatusController.sink
        .add(const PromptServiceConnectionStatus.connecting());

    if (_socket.connected) {
      _logger.d('Already connected to server');
      _connectionStatusController.sink
          .add(const PromptServiceConnectionStatus.connected());
      return;
    }

    _connectionStatusListeners.addAll([
      _socket.onConnect((_) {
        _logger.d('Connected to server');
        _connectionStatusController.sink
            .add(const PromptServiceConnectionStatus.connected());
      }),
      _socket.onConnectError((data) {
        _logger.e('Connect error: $data');
        if (data is SocketException) {
          _connectionStatusController.sink
              .add(PromptServiceConnectionStatus.error(data.message));
        } else {
          _connectionStatusController.sink
              .add(PromptServiceConnectionStatus.error('$data'));
        }
      }),
      _socket.onReconnect((data) {
        _logger.d('Reconnected to server');
        _connectionStatusController.sink
            .add(const PromptServiceConnectionStatus.connected());
      }),
      _socket.onReconnectError((data) {
        _logger.e('Reconnect error: $data');
        if (_connectionStatusController.isClosed) return;
        if (data is SocketException) {
          _connectionStatusController.sink
              .add(PromptServiceConnectionStatus.error(data.message));
        } else {
          _connectionStatusController.sink
              .add(PromptServiceConnectionStatus.error('$data'));
        }
      }),
      _socket.onDisconnect((_) {
        _streaming = false;
        _logger.d('Disconnected from server');

        if (!_endController.isClosed) {
          _endController.sink.add(null);
        }

        if (!_connectionStatusController.isClosed) {
          _connectionStatusController.sink
              .add(const PromptServiceConnectionStatus.disconnected());
        }
      })
    ]);

    _logger.d('Listening to server events');

    _socket.on('chunk', (data) {
      _streaming = true;
      _responseController.sink.add(data);
    });

    _socket.on('end', (_) {
      _logger.d('Received end event');
      _streaming = false;
      _endController.sink.add(null);
    });

    _socket.on('error', _onEventError);

    _socket.on('exception', _onEventError);
  }

  _onEventError(error) {
    _logger.e('Received error: $error');
    _streaming = false;

    if (error is Map && error.containsKey('message')) {
      final message = error['message'] as String;
      final displayMessage = buildrStudioErrorMessages[message] ?? message;
      _errorController.sink.add(displayMessage);
    } else {
      _errorController.sink.add(error.toString());
    }
  }

  @override
  void sendPrompt({
    required String prompt,
    String? deviceKey,
  }) async {
    if (deviceKey == null) {
      _errorController.sink.add('Unable to get account information.');
      return;
    }
    try {
      if (_streaming) {
        _socket.emit('cancel');
      }
      _socket.emit('prompt', await _buildAuthenticatedRequest(prompt));
    } catch (e) {
      _logger.e('Error sending prompt: $e');
      _streaming = false;
      _errorController.sink.add(e.toString());
    }
  }

  @override
  Stream<String> get responseStream => _responseController.stream;
  @override
  Stream<String> get errorStream => _errorController.stream;
  @override
  Stream<void> get endStream => _endController.stream;

  @override
  Stream<PromptServiceConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  @override
  void dispose() {
    _responseController.close();
    _errorController.close();
    _endController.close();
    _connectionStatusController.close();
    _socket.clearListeners();
    _socket.disconnect();
    for (var listener in _connectionStatusListeners) {
      listener();
    }
  }

  Future<Map<String, dynamic>> _buildAuthenticatedRequest(String prompt) async {
    final request = await _requestBuilder.build(prompt);
    return {
      'prompt': request.data,
      'signature': request.signature,
      'privateKeyHash': request.deviceKeyHash,
    };
  }
}

enum ErrorCodes {
  tooManyRequests,
  insufficientBalance,
  exceededTokenPerMinute,
  exceededTokenPerDay
}

final buildrStudioErrorMessages = {
  ErrorCodes.tooManyRequests.name:
      'You have reached the maximum number of requests in 1 minute. Please wait a moment and try again.',
  ErrorCodes.insufficientBalance.name:
      'Insufficient balance. Please top up your account.',
  ErrorCodes.exceededTokenPerMinute.name:
      'Exceeded token per minute limit. Please wait a moment and try again.',
  ErrorCodes.exceededTokenPerDay.name:
      'Exceeded token per day limit. Please wait until tomorrow and try again.',
};
