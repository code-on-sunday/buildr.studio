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
}
