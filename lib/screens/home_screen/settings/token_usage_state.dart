import 'dart:async';

import 'package:buildr_studio/models/token_usage.dart';
import 'package:buildr_studio/repositories/account_repository.dart';
import 'package:buildr_studio/repositories/user_preferences_repository.dart';
import 'package:flutter/material.dart';

class TokenUsageState extends ChangeNotifier {
  TokenUsageState({
    required UserPreferencesRepository userPreferencesRepository,
    required AccountRepository accountRepository,
  })  : _accountRepository = accountRepository,
        _userPreferencesRepository = userPreferencesRepository;

  final UserPreferencesRepository _userPreferencesRepository;
  final AccountRepository _accountRepository;

  TokenUsage? _tokenUsage;
  String? _errorMessage;
  bool _isLoading = false;

  TokenUsage? get tokenUsage => _tokenUsage;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> loadTokenUsage() async {
    try {
      _isLoading = true;
      notifyListeners();
      final accountId = _userPreferencesRepository.getAccountId();
      if (accountId == null) {
        _errorMessage = 'Account ID is not set';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _tokenUsage = await _accountRepository.getTokenUsage(accountId);
    } catch (e) {
      _errorMessage = 'Error loading token usage: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
