import 'package:buildr_studio/repositories/user_preferences_repository.dart';
import 'package:flutter/material.dart';

class ChooseAIServiceState extends ChangeNotifier {
  ChooseAIServiceState(
      {required UserPreferencesRepository userPreferencesRepository})
      : _userPreferencesRepository = userPreferencesRepository {
    _loadStoredService();
  }

  final UserPreferencesRepository _userPreferencesRepository;
  AIService _selectedService = AIService.buildrStudio;

  AIService get selectedService => _selectedService;

  void setSelectedService(AIService service) {
    _selectedService = service;
    _userPreferencesRepository.setAiService(service);
    notifyListeners();
  }

  void _loadStoredService() {
    _selectedService = _userPreferencesRepository.getAiService();
    notifyListeners();
  }
}

enum AIService {
  buildrStudio("buildr.studio"),
  anthropic("Anthropic", keyName: 'anthropic_api_key'),
  google("Google", keyName: 'google_api_key');

  final String displayName;
  final String? keyName;

  const AIService(this.displayName, {this.keyName});
}
