class GitIgnoreChecker {
  static bool isPathIgnored(String gitIgnoreContent, String path) {
    try {
      final lines = gitIgnoreContent.split('\n');
      bool isIgnored = false;
      bool isNegated = false;
      for (final rule in lines) {
        final trimmedRule = rule.trim();
        if (trimmedRule.isNotEmpty) {
          if (trimmedRule.startsWith('!')) {
            isNegated = !isNegated;
            if (_matchesRule(trimmedRule.substring(1).trim(), path)) {
              isIgnored = !isIgnored;
            }
          } else if (_matchesRule(trimmedRule, path)) {
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

  static bool _matchesRule(String rule, String path) {
    // Handle different types of rules (e.g., literal matches, wildcards, negation)
    if (rule.contains('*')) {
      final regex = rule.replaceAll('.', '\\.').replaceAll('*', '.*');
      return RegExp(regex).hasMatch(path);
    } else if (rule.endsWith('/')) {
      final ruleWithoutSlash = rule.substring(0, rule.length - 1);
      return path.startsWith(ruleWithoutSlash) &&
          (path == ruleWithoutSlash ||
              path.substring(ruleWithoutSlash.length).contains('/'));
    } else {
      final pathParts = path.split('/');
      final ruleParts = rule.split('/');
      if (ruleParts.length == 1 && !rule.startsWith("/")) {
        return pathParts.contains(rule);
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
