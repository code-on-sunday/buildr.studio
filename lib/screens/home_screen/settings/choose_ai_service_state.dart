import 'package:flutter/material.dart';

class ChooseAIServiceState extends ChangeNotifier {
  AIService _selectedService = AIService.buildrStudio;

  AIService get selectedService => _selectedService;

  void setSelectedService(AIService service) {
    _selectedService = service;
    notifyListeners();
  }
}

enum AIService {
  buildrStudio("buildr.studio"),
  anthropic("Anthropic");

  final String displayName;

  const AIService(this.displayName);
}
