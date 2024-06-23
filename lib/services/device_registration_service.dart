import 'dart:async';
import 'dart:io';

import 'package:buildr_studio/env/env.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DeviceRegistrationService {
  Completer<String>? _deviceKeyCompleter;

  Future<String> loadDeviceKey() async {
    final directory = await getApplicationSupportDirectory();
    final deviceKeyPath = p.join(directory.path, 'device_key');

    if (File(deviceKeyPath).existsSync()) {
      return await File(deviceKeyPath).readAsString();
    }

    if (_deviceKeyCompleter != null) {
      return _deviceKeyCompleter!.future;
    }

    _deviceKeyCompleter = Completer<String>();

    _runRegistrationProcess(directory, deviceKeyPath).then((deviceKey) {
      _deviceKeyCompleter!.complete(deviceKey);
    }).catchError((e) {
      _deviceKeyCompleter!.completeError(e);
    });

    return _deviceKeyCompleter!.future;
  }

  Future<String> _runRegistrationProcess(
      Directory directory, String deviceKeyPath) async {
    final logPath = p.join(directory.path, 'device_registration.log');

    final String appExePath = Platform.resolvedExecutable;
    final String appPath = p.dirname(appExePath);
    final String exePath = Platform.isWindows
        ? p.joinAll([appPath, ...Env.deviceRegistrationExePath.split(",")])
        : p.join(appPath, 'device_registration');

    final relativePath = p.relative(exePath, from: p.current);

    final process = await Process.start(
      relativePath,
      [deviceKeyPath, logPath],
    );

    String err = '';
    process.stderr.listen((event) {
      err = err + String.fromCharCodes(event);
    });

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      final errorMessage =
          'Registration process failed with exit code $exitCode\n$err';
      throw Exception(errorMessage);
    }

    return await File(deviceKeyPath).readAsString();
  }
}
