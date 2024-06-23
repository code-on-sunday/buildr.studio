import 'dart:async';
import 'dart:io';

import 'package:buildr_studio/env/env.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DeviceRegistrationService {
  final _logger = GetIt.I.get<Logger>();
  Completer<String>? _deviceKeyCompleter;

  Future<String> loadDeviceKey() async {
    final directory = await getApplicationSupportDirectory();
    final deviceKeyPath = p.join(directory.path, 'device_key');

    if (File(deviceKeyPath).existsSync()) {
      return await File(deviceKeyPath).readAsString();
    }

    _logger.d('Device key not found, running registration process');

    if (_deviceKeyCompleter != null) {
      return _deviceKeyCompleter!.future;
    }

    _deviceKeyCompleter = Completer<String>();

    _runRegistrationProcess(directory, deviceKeyPath).then((deviceKey) {
      _deviceKeyCompleter!.complete(deviceKey);
      _deviceKeyCompleter = null;
    }).catchError((e) {
      _deviceKeyCompleter!.completeError(e);
      _deviceKeyCompleter = null;
    });

    return _deviceKeyCompleter!.future;
  }

  Future<String> _runRegistrationProcess(
      Directory directory, String deviceKeyPath) async {
    _logger.d('Running device registration process');

    final logPath = p.join(directory.path, 'device_registration.log');
    final String appExePath = Platform.resolvedExecutable;
    final String appPath = p.dirname(appExePath);
    final String exePath = Platform.isWindows
        ? p.joinAll([appPath, ...Env.deviceRegistrationExePath.split(",")])
        : p.join(appPath, 'device_registration');

    if (!File(exePath).existsSync()) {
      throw Exception('Device registration executable not found at $exePath');
    }

    _logger.d('Device registration executable found at $exePath');

    if (File(exePath).statSync().mode & 0x49 != 0x49) {
      throw Exception(
          'Device registration executable at $exePath is not executable');
    }

    _logger.d('Device registration executable has executable permissions');

    final process = await Process.start(
      exePath,
      [deviceKeyPath, logPath],
    );

    String err = '';
    process.stderr.listen((event) {
      err = err + String.fromCharCodes(event);
    });

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      final errorMessage =
          'Ran $exePath\nProcess failed with exit code $exitCode\n$err';
      throw Exception(errorMessage);
    }

    return await File(deviceKeyPath).readAsString();
  }
}
