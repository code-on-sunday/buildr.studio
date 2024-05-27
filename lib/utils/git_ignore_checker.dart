import 'package:path/path.dart' as path;

class GitIgnoreChecker {
  static bool isPathIgnored(String gitIgnoreContent, String pathToCheck) {
    if (pathToCheck.split(path.separator).contains(".git")) {
      return true;
    }
    try {
      final lines = gitIgnoreContent.split('\n');
      bool isIgnored = false;
      bool isNegated = false;
      for (final rule in lines) {
        final trimmedRule = rule.trim();
        if (trimmedRule.isNotEmpty) {
          if (trimmedRule.startsWith('!')) {
            isNegated = !isNegated;
            if (_matchesRule(trimmedRule.substring(1).trim(), pathToCheck)) {
              isIgnored = !isIgnored;
            }
          } else if (_matchesRule(trimmedRule, pathToCheck)) {
            isIgnored = !isNegated;
          }
        }
      }
      return isIgnored;
    } catch (e) {
      // Log or display the error to the UI
      print('Error checking Git ignore: $e');
      return false;
    }
  }

  static bool _matchesRule(String rule, String pathToCheck) {
    var normalizedPath = pathToCheck.replaceAll(r'\', '/');
    final normalizedRule = rule;

    if (normalizedRule.contains('*')) {
      final regex = normalizedRule.replaceAll('.', '\\.').replaceAll('*', '.*');
      return RegExp(regex).hasMatch(normalizedPath);
    } else if (normalizedRule.endsWith("/")) {
      final ruleWithoutSlash =
          normalizedRule.substring(0, normalizedRule.length - 1);
      return normalizedPath.startsWith(ruleWithoutSlash) ||
          normalizedPath == ruleWithoutSlash ||
          normalizedPath.contains('/$ruleWithoutSlash/');
    } else {
      final pathParts = normalizedPath.split("/");
      final ruleParts = normalizedRule.split("/");
      if (ruleParts.length == 1 && !normalizedRule.startsWith("/")) {
        return pathParts.contains(normalizedRule);
      }
      if (pathParts.length >= ruleParts.length) {
        for (int i = 0; i < ruleParts.length; i++) {
          if (ruleParts[i] != pathParts[i]) {
            return false;
          }
        }
        return true;
      } else {
        return false;
      }
    }
  }
}
