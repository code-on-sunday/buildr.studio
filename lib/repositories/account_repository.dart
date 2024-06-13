import 'package:buildr_studio/models/token_usage.dart';
import 'package:buildr_studio/services/prompt_service/authenticated_buildr_studio_request_builder.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class AccountRepository {
  AccountRepository({
    required Dio dio,
    required AuthenticatedBuildrStudioRequestBuilder buildrStudioRequestBuilder,
  })  : _dio = dio,
        _buildrStudioRequestBuilder = buildrStudioRequestBuilder;

  final _logger = GetIt.I.get<Logger>();
  final Dio _dio;
  final AuthenticatedBuildrStudioRequestBuilder _buildrStudioRequestBuilder;

  Future<String> getAccountId(String deviceKey) async {
    final hash = _buildrStudioRequestBuilder.getDeviceKeyHash(deviceKey);
    final response = await _dio.get('/auth/account-id/$hash');
    _logger.d('Account ID response: ${response.data}');
    return response.data;
  }

  Future<TokenUsage> getTokenUsage(String accountId) async {
    _logger.d('Getting token usage for account ID: $accountId');
    final response = await _dio.get('/auth/token-usage/$accountId');

    _logger.d('Token usage response: ${response.data}');

    return TokenUsage.fromJson(response.data);
  }
}
