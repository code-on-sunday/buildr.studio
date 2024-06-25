import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', allowOptionalFields: true)
abstract class Env {
  @EnviedField(varName: 'WIREDASH_SECRET', obfuscate: true)
  static final String? wireDashSecret = _Env.wireDashSecret;
  @EnviedField(varName: 'WIREDASH_PROJECT_ID', obfuscate: true)
  static final String? wireDashProjectId = _Env.wireDashProjectId;
  @EnviedField(varName: 'API_BASE_URL', obfuscate: true)
  static final String apiBaseUrl = _Env.apiBaseUrl;
  @EnviedField(varName: 'WEB_BASE_URL')
  static const String webBaseUrl = _Env.webBaseUrl;
  @EnviedField(varName: 'DEVICE_KEY_HASH_SALT', obfuscate: true)
  static final String deviceHashSalt = _Env.deviceHashSalt;
  @EnviedField(varName: 'DEVICE_REGISTRATION_EXE_PATH', obfuscate: true)
  static final String deviceRegistrationExePath =
      _Env.deviceRegistrationExePath;
  @EnviedField(varName: 'LOG_AES_KEY', obfuscate: true)
  static final String logAesKey = _Env.logAesKey;
  @EnviedField(varName: 'LOG_AES_NONCE', obfuscate: true)
  static final String logAesNonce = _Env.logAesNonce;
  @EnviedField(varName: 'MEASUREMENT_PROTOCOL_API_SECRET', obfuscate: true)
  static final String measurementProtocolApiSecret =
      _Env.measurementProtocolApiSecret;
  @EnviedField(varName: 'MEASUREMENT_ID', obfuscate: true)
  static final String measurementId = _Env.measurementId;
}
