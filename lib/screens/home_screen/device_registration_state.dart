import 'package:buildr_studio/utils/device_registration.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DeviceRegistrationState extends ChangeNotifier {
  final DeviceRegistration _deviceRegistration = GetIt.I<DeviceRegistration>();
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
