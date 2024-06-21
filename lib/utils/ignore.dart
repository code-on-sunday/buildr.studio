import 'dart:core';

List<String> makeArray(dynamic subject) {
  return subject is List ? subject as List<String> : [subject];
}

const EMPTY = '';
const SPACE = ' ';
const ESCAPE = '\\';
final REGEX_TEST_BLANK_LINE = RegExp(r'^\s+$');
final REGEX_INVALID_TRAILING_BACKSLASH = RegExp(r'(?:[^\\]|^)\$');
final REGEX_REPLACE_LEADING_ESCAPED_EXCLAMATION = RegExp(r'^\\!');
final REGEX_REPLACE_LEADING_ESCAPED_HASH = RegExp(r'^\\#');
final REGEX_SPLITALL_CRLF = RegExp(r'\r?\n');
final REGEX_TEST_INVALID_PATH = RegExp(r'^\.*\/|^\.+$');
const SLASH = '/';

const KEY_IGNORE = 'node-ignore';

Map<String, dynamic> regexCache = {};

final REGEX_REGEXP_RANGE = RegExp(r'([0-z])-([0-z])');
bool RETURN_FALSE([dynamic arg1, dynamic arg2]) => false;

String sanitizeRange(String range) {
  return range.replaceAllMapped(REGEX_REGEXP_RANGE, (match) {
    return match.group(1)!.codeUnitAt(0) <= match.group(2)!.codeUnitAt(0)
        ? match.group(0)!
        : EMPTY;
  });
}

String cleanRangeBackSlash(String slashes) {
  int length = slashes.length;
  return slashes.substring(0, length - length % 2);
}

final List<(RegExp, String Function(Match))> REPLACERS = [
  // Remove BOM
  (RegExp(r'^\uFEFF'), (Match match) => EMPTY),

  // Trailing spaces are ignored unless they are quoted with backslash ("\")
  (
    RegExp(r'\\?\s+$'),
    (Match match) => match.group(0)!.startsWith('\\') ? SPACE : EMPTY
  ),

  // Replace (\ ) with ' '
  (RegExp(r'\\\s'), (Match match) => SPACE),

  // Escape metacharacters which have special meanings in regex
  (RegExp(r'[\\$.|*+(){^]'), (Match match) => '\\${match.group(0)}'),

  // A question mark (?) matches a single character
  (RegExp(r'(?!\\)\?'), (Match match) => '[^/]'),

  // A leading slash matches the beginning of the pathname
  (RegExp(r'^/'), (Match match) => '^'),

  // Replace special metacharacter slash after the leading slash
  (RegExp(r'\/'), (Match match) => '\\/'),

  // A leading "**" followed by a slash means match in all directories
  (RegExp(r'^\^*\\\*\\\*\\\/'), (Match match) => '^(?:.*\\/)?'),

  // Starting pattern
  (
    RegExp(r'^(?=[^^])'),
    (Match match) {
      return !RegExp(r'/(?!$)').hasMatch(match.input) ? r'(?:^|\/)' : '^';
    }
  ),

  // Use lookahead assertions to match more than one `'/**'`
  (
    RegExp(r'\\\/\\\*\\\*(?=\\\/|\$)'),
    (Match match) {
      final str = match.input;
      final index = match.start;
      return index + 6 < str.length ? '(?:\\/[^\\/]+)*' : '\\/.+';
    }
  ),

  // Normal intermediate wildcards
  (
    RegExp(r'(^|[^\\]+)(\\\*)+(?=.+)'),
    (Match match) {
      final p1 = match.group(1)!;
      final p2 = match.group(2)!;
      return p1 + p2.replaceAll(RegExp(r'\\\*'), '[^\\/]*');
    }
  ),

  // Unescape, revert step 3 except for back slash
  (RegExp(r'\\\\\\(?=[$.|*+(){^])'), (Match match) => ESCAPE),

  // '\\\\' -> '\\'
  (RegExp(r'\\\\'), (Match match) => ESCAPE),

  // The range notation can be used to match one of the characters in a range
  (
    RegExp(r'(\\)?\[([^\]/]*?)(\\*)($|\])'),
    (Match match) {
      final leadEscape = match.group(1);
      final range = match.group(2)!;
      final endEscape = match.group(3)!;
      final close = match.group(4)!;
      return leadEscape == ESCAPE
          ? '\\[$range${cleanRangeBackSlash(endEscape)}$close'
          : close == ']'
              ? endEscape.length % 2 == 0
                  ? '[$sanitizeRange(range)$endEscape]'
                  : '[]'
              : '[]';
    }
  ),

  // Ending pattern
  (
    RegExp(r'(?:[^*])$'),
    (Match match) => match.group(0)!.endsWith('/')
        ? '${match.group(0)}\$'
        : '${match.group(0)}(?=\$|\\/\$)'
  ),

  // Trailing wildcard
  (
    RegExp(r'(\^|\\\/)?\\\*$'),
    (Match match) {
      final p1 = match.group(1) ?? '';
      return p1.isNotEmpty ? '$p1[^/]+(?=\$|\\/\$)' : '[^/]*(?=\$|\\/\$)';
    }
  )
];

RegExp makeRegex(String pattern, bool ignoreCase) {
  if (!regexCache.containsKey(pattern)) {
    String source = REPLACERS.fold(pattern, (prev, current) {
      final regExp = current.$1;
      final replacer = current.$2;
      return prev.replaceAllMapped(regExp, replacer);
    });
    regexCache[pattern] = source;
  }
  return RegExp(regexCache[pattern]!, caseSensitive: !ignoreCase);
}

bool isString(dynamic subject) {
  return subject is String && subject.isNotEmpty;
}

bool checkPattern(String pattern) {
  return pattern.isNotEmpty &&
      isString(pattern) &&
      !REGEX_TEST_BLANK_LINE.hasMatch(pattern) &&
      !REGEX_INVALID_TRAILING_BACKSLASH.hasMatch(pattern) &&
      !pattern.startsWith('#');
}

List<String> splitPattern(String pattern) {
  return pattern.split(REGEX_SPLITALL_CRLF);
}

class IgnoreRule {
  final String origin;
  final String pattern;
  final bool negative;
  final RegExp regex;

  IgnoreRule(this.origin, this.pattern, this.negative, this.regex);

  @override
  String toString() {
    return 'IgnoreRule{origin: $origin, pattern: $pattern, negative: $negative, regex: $regex}';
  }
}

IgnoreRule createRule(String pattern, bool ignoreCase) {
  String origin = pattern;
  bool negative = false;

  if (pattern.startsWith('!')) {
    negative = true;
    pattern = pattern.substring(1);
  }

  pattern = pattern
      .replaceFirst(REGEX_REPLACE_LEADING_ESCAPED_EXCLAMATION, '!')
      .replaceFirst(REGEX_REPLACE_LEADING_ESCAPED_HASH, '#');

  RegExp regex = makeRegex(pattern, ignoreCase);

  return IgnoreRule(origin, pattern, negative, regex);
}

void throwError(String message, [Type errorType = Error]) {
  throw Exception(message);
}

bool checkPath(String path, String originalPath, Function doThrow) {
  if (!isString(path)) {
    doThrow('path must be a string, but got `$originalPath`', TypeError);
    return false;
  }

  if (path.isEmpty) {
    doThrow('path must not be empty', TypeError);
    return false;
  }

  if (isNotRelative(path)) {
    String r = '`path.relative()`d';
    doThrow('path should be a $r string, but got "$originalPath"', RangeError);
    return false;
  }

  return true;
}

bool isNotRelative(String path) {
  return REGEX_TEST_INVALID_PATH.hasMatch(path);
}

class Ignore {
  final bool ignoreCase;
  final bool allowRelativePaths;
  final List<IgnoreRule> _rules = [];
  Map<String, Map<String, bool>> _ignoreCache = {};
  Map<String, Map<String, bool>> _testCache = {};
  bool _added = false;

  Ignore({this.ignoreCase = true, this.allowRelativePaths = false}) {
    _initCache();
  }

  void _initCache() {
    _ignoreCache = {};
    _testCache = {};
  }

  void _addPattern(String pattern) {
    if (pattern.isNotEmpty && pattern.startsWith(KEY_IGNORE)) {
      _rules.addAll((pattern as Ignore)._rules);
      _added = true;
      return;
    }

    if (checkPattern(pattern)) {
      IgnoreRule rule = createRule(pattern, ignoreCase);
      _added = true;
      _rules.add(rule);
    }
  }

  Ignore add(dynamic pattern) {
    _added = false;

    makeArray(isString(pattern) ? splitPattern(pattern) : pattern)
        .forEach(_addPattern);

    if (_added) {
      _initCache();
    }

    return this;
  }

  Ignore addPattern(String pattern) {
    return add(pattern);
  }

  Map<String, bool> _testOne(String path, bool checkUnignored) {
    bool ignored = false;
    bool unignored = false;

    for (var rule in _rules) {
      bool negative = rule.negative;
      if ((unignored == negative && ignored != unignored) ||
          (negative && !ignored && !unignored && !checkUnignored)) {
        continue;
      }

      bool matched = rule.regex.hasMatch(path);

      // print('$path - $rule - $matched');

      if (matched) {
        ignored = !negative;
        unignored = negative;
      }
    }

    return {'ignored': ignored, 'unignored': unignored};
  }

  Map<String, bool> _test(
      String originalPath,
      Map<String, Map<String, bool>> cache,
      bool checkUnignored,
      List<String>? slices) {
    String path = originalPath.isEmpty ? originalPath : originalPath;

    checkPath(
        path, originalPath, allowRelativePaths ? RETURN_FALSE : throwError);

    return _t(path, cache, checkUnignored, slices);
  }

  Map<String, bool> _t(String path, Map<String, Map<String, bool>> cache,
      bool checkUnignored, List<String>? slices) {
    if (cache.containsKey(path)) {
      return cache[path]!;
    }

    slices ??= path.split(SLASH);
    slices.removeLast();

    if (slices.isEmpty) {
      return cache[path] = _testOne(path, checkUnignored);
    }

    var parent = _t(slices.join(SLASH) + SLASH, cache, checkUnignored, slices);

    // print('_t $path - $parent');

    return cache[path] =
        parent['ignored']! ? parent : _testOne(path, checkUnignored);
  }

  bool ignores(String path) {
    return _test(path, _ignoreCache, false, null)['ignored']!;
  }

  bool Function(String) createFilter() {
    return (path) => !ignores(path);
  }

  List<String> filter(List<String> paths) {
    return makeArray(paths).where(createFilter()).toList();
  }

  Map<String, bool> test(String path) {
    return _test(path, _testCache, true, null);
  }
}

Ignore factory([Map<String, dynamic>? options]) {
  return Ignore(
      ignoreCase: options?['ignorecase'] ?? true,
      allowRelativePaths: options?['allowRelativePaths'] ?? false);
}

bool isPathValid(String path) {
  return checkPath(path.isEmpty ? path : path, path, RETURN_FALSE);
}
