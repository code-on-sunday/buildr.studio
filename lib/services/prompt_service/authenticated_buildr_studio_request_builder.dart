import 'dart:convert';

import 'package:buildr_studio/env/env.dart';
import 'package:buildr_studio/services/device_registration_service.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

class AuthenticatedBuildrStudioRequest {
  final String data;
  final String signature;
  final String deviceKeyHash;

  AuthenticatedBuildrStudioRequest(
      this.data, this.signature, this.deviceKeyHash);
}

class AuthenticatedBuildrStudioRequestBuilder {
  final DeviceRegistrationService _deviceRegistrationService;

  AuthenticatedBuildrStudioRequestBuilder(this._deviceRegistrationService);

  Future<AuthenticatedBuildrStudioRequest> build(String data) async {
    final deviceKey = await _getDeviceKey();
    final signature = await _signWithDeviceKey(data, deviceKey);
    final deviceKeyHash = getDeviceKeyHash(deviceKey);

    return AuthenticatedBuildrStudioRequest(data, signature, deviceKeyHash);
  }

  Future<String> _getDeviceKey() {
    return _deviceRegistrationService.loadDeviceKey();
  }

  Future<String> _signWithDeviceKey(String data, String deviceKey) async {
    final rsaPrivateKey = RSAKeyParser().parse(deviceKey) as RSAPrivateKey;
    final signer =
        Signer(RSASigner(RSASignDigest.SHA256, privateKey: rsaPrivateKey));
    return signer.sign(data).base64;
  }

  String getDeviceKeyHash(String deviceKey) {
    final salt = Env.deviceHashSalt;
    final concatenated = '$deviceKey:$salt';
    final bytes = utf8.encode(concatenated);
    final hash = sha256.convert(bytes).toString();
    return hash;
  }
}
