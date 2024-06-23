import 'dart:io';

import 'package:buildr_studio/env/env.dart';
import 'package:encrypt/encrypt.dart';
import 'package:path/path.dart' as path;

class LogFileDecryptor {
  void writeDecryptedLogs(String logFilePath) async {
    final decryptedLogs = await decryptLogFile(logFilePath);
    final output =
        File(path.join(path.dirname(logFilePath), 'decrypted_logs.txt'));
    if (!output.existsSync()) output.createSync();
    output.writeAsStringSync(decryptedLogs ?? '');
  }

  Future<String?> decryptLogFile(String logFilePath) async {
    try {
      final file = File(logFilePath);
      final encryptedContent = await file.readAsString();

      final decryptedContent = decryptLogs(encryptedContent);

      return decryptedContent;
    } catch (e) {
      print(e);
      return null;
    }
  }

  String decryptLogs(String encryptedLogs) {
    final key = Key.fromUtf8(Env.logAesKey);
    final iv = IV.fromUtf8(Env.logAesNonce);
    final decryptedLogs = _decryptAES(encryptedLogs, key, iv);
    return decryptedLogs;
  }

  String _decryptAES(String encryptedData, Key key, IV iv) {
    final cipher = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted =
        cipher.decrypt(Encrypted.fromBase16(encryptedData), iv: iv);
    return decrypted;
  }
}
