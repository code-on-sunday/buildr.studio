import 'package:ambilytics/ambilytics.dart';
import 'package:buildr_studio/analytics_events.dart';
import 'package:buildr_studio/repositories/account_repository.dart';
import 'package:buildr_studio/repositories/user_preferences_repository.dart';
import 'package:buildr_studio/services/device_registration_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class DeviceRegistrationState extends ChangeNotifier {
  DeviceRegistrationState({
    required DeviceRegistrationService deviceRegistration,
    required AccountRepository accountRepository,
    required UserPreferencesRepository userPreferencesRepository,
  })  : _deviceRegistration = deviceRegistration,
        _accountRepository = accountRepository,
        _userPreferencesRepository = userPreferencesRepository {
    registerDevice();
  }

  final _logger = GetIt.I.get<Logger>();

  final DeviceRegistrationService _deviceRegistration;
  final AccountRepository _accountRepository;
  final UserPreferencesRepository _userPreferencesRepository;
  String? accountId;
  String? errorMessage;

  Future<String?> registerDevice() async {
    try {
      errorMessage = null;
      var deviceKey = await _deviceRegistration.loadDeviceKey();
      var id = accountId = await _accountRepository.getAccountId(deviceKey);

      // Solve the issue of multiple devices registered to the same account id 427 in the past by re-registering the device
      if (id == '427') {
        ambilytics?.sendEvent(AnalyticsEvents.account427Removed.name, null);
        await _deviceRegistration.deleteDeviceKey();
        deviceKey = await _deviceRegistration.loadDeviceKey();
        id = accountId = await _accountRepository.getAccountId(deviceKey);
      }

      _userPreferencesRepository.setAccountId(id);
      notifyListeners();
      return deviceKey;
    } catch (e) {
      _logger.e('Error registering device: $e');
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
}
