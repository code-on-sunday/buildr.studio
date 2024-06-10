import 'package:buildr_studio/services/device_registration_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DeviceRegistrationState extends ChangeNotifier {
  final DeviceRegistrationService _deviceRegistration =
      GetIt.I<DeviceRegistrationService>();
  String? errorMessage;

  Future<void> registerDevice() async {
    try {
      await _deviceRegistration.register();
    } catch (e) {
      print('Error registering device: $e');
      errorMessage = e.toString();
    }
    notifyListeners();
  }
}
