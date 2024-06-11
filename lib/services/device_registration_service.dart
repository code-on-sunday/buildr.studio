import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DeviceRegistrationService {
  Future<String> loadDeviceKey() async {
    final directory = await getApplicationSupportDirectory();
    final deviceKeyPath = p.join(directory.path, 'device_key');

    if (File(deviceKeyPath).existsSync()) {
      return await File(deviceKeyPath).readAsString();
    }

    final deviceRegistrationPath =
        p.join(directory.path, 'device_registration.log');

    final String appExePath = Platform.resolvedExecutable;
    final String appPath = p.dirname(appExePath);
    final String exePath = p.joinAll([
      appPath,
      'data',
      'flutter_assets',
      'assets',
      'device_registration.exe'
    ]);
    final process = await Process.start(
      exePath,
      [deviceKeyPath, deviceRegistrationPath],
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
