import 'dart:async';

import 'package:buildr_studio/utils/logs_exporter.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ExportLogsState extends ChangeNotifier {
  ExportLogsState({required LogsExporter logsExporter})
      : _logsExporter = logsExporter;

  final _logger = GetIt.I.get<Logger>();
  final LogsExporter _logsExporter;
  bool _isRunning = false;
  String? _error;

  bool get isRunning => _isRunning;
  String? get error => _error;

  Future<void> exportLogs(BuildContext context) async {
    try {
      _isRunning = true;
      notifyListeners();

      final zipFilePath = await _logsExporter.createZipFile();
      if (zipFilePath != null) {
        _logsExporter.findResult(
          dirname(zipFilePath),
        );
      } else {
        _error = 'Failed to create zip file';
        _logger.e(_error);
        showSnackBarError(context, _error!);
      }
    } catch (e, stackTrace) {
      _error = 'Error creating zip file: $e';
      _logger.e('Error creating zip file', error: e, stackTrace: stackTrace);
      showSnackBarError(context, _error!);
    } finally {
      _isRunning = false;
      notifyListeners();
    }
  }

  void showSnackBarError(BuildContext context, String errorMessage) {
    ShadToaster.of(context).show(
      ShadToast.destructive(
        description: Text(errorMessage),
      ),
    );
  }
}
