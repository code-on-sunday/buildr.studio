import 'dart:io';

import 'package:buildr_studio/utils/ignore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('makeRegex', () {
    test('should return a RegExp object with correct pattern', () {
      expect(makeRegex('test/*', true).pattern, r'^test\/[^/]+(?=$|\/$)');
      expect(makeRegex('.abc/', true).pattern, r'(?:^|\/)\.abc\/$');
      expect(makeRegex('abc/', true).pattern, r'(?:^|\/)abc\/$');
      expect(makeRegex('/abc/', true).pattern, r'^abc\/$');
    });
  });

  group('Load gitignore file and test paths', () {
    late Ignore ignore;

    setUp(() {
      ignore = Ignore();
      // Read gitignore file and add rules to ignore instance
      final gitignoreFile = File('.gitignore');
      final rules = gitignoreFile.readAsLinesSync();
      ignore.add(rules);
      // ignore.add(['/build/']);
    });

    test('Test paths against gitignore rules', () {
      final cases = {
        '*.class': ['file.class', 'dir/file.class'],
        '*.log': ['file.log', 'dir/file.log'],
        '*.pyc': ['file.pyc', 'dir/file.pyc'],
        '*.swp': ['file.swp', 'dir/file.swp'],
        '.DS_Store': ['.DS_Store'],
        '.atom/': ['.atom/', 'dir/.atom/'],
        '.buildlog/': ['.buildlog/', 'dir/.buildlog/'],
        '.history': ['.history'],
        '.svn/': ['.svn/', 'dir/.svn/'],
        'migrate_working_dir/': [
          'migrate_working_dir/',
          'dir/migrate_working_dir/'
        ],
        '*.iml': ['file.iml', 'dir/file.iml'],
        '*.ipr': ['file.ipr', 'dir/file.ipr'],
        '*.iws': ['file.iws', 'dir/file.iws'],
        '.idea/': ['.idea/', 'dir/.idea/'],
        '**/doc/api/': ['doc/api/', 'dir/doc/api/'],
        '**/ios/Flutter/.last_build_id': [
          'ios/Flutter/.last_build_id',
          'dir/ios/Flutter/.last_build_id'
        ],
        '.dart_tool/': ['.dart_tool/', 'dir/.dart_tool/'],
        '.flutter-plugins': ['.flutter-plugins'],
        '.flutter-plugins-dependencies': ['.flutter-plugins-dependencies'],
        '.pub-cache/': ['.pub-cache/', 'dir/.pub-cache/'],
        '.pub/': ['.pub/', 'dir/.pub/'],
        '/build/': ['build/', 'build/abc'],
        'app.*.symbols': ['app.debug.symbols', 'app.release.symbols'],
        'app.*.map.json': ['app.debug.map.json', 'app.release.map.json'],
        '/android/app/debug': ['android/app/debug', 'android/app/debug/abc'],
        '/android/app/profile': [
          'android/app/profile',
          'android/app/profile/abc'
        ],
        '/android/app/release': [
          'android/app/release',
          'android/app/release/abc'
        ],
        '/.venv/': ['.venv/', '.venv/abc/d'],
        '**/failures/*.png': ['failures/test.png', 'dir/failures/test.png'],
        '.env': ['.env'],
        'macos/Podfile.lock': ['macos/Podfile.lock'],
        '*.exe': ['file.exe', 'dir/file.exe'],
        'lib/env/env.g.dart': ['lib/env/env.g.dart']
      };

      cases.forEach((pattern, paths) {
        for (var path in paths) {
          expect(ignore.ignores(path), isTrue,
              reason: 'Path $path should be ignored by pattern $pattern');
        }
      });

      // Test paths that should not be ignored
      final nonIgnoredPaths = [
        'src/main.dart',
        'lib/main.dart',
        'README.md',
        'some_folder/another_file.txt'
      ];

      for (var path in nonIgnoredPaths) {
        expect(ignore.ignores(path), isFalse,
            reason: 'Path $path should not be ignored');
      }
    });
  });

  group('Ignore Class Tests', () {
    late Ignore ignore;

    setUp(() {
      ignore = Ignore();
    });

    test('Add pattern and check if it ignores the correct paths', () {
      ignore.add('test/');
      expect(ignore.ignores('test/'), isTrue);
      expect(ignore.ignores('test/file.txt'), isTrue);
      expect(ignore.ignores('not_test/'), isFalse);
    });

    test('Add multiple patterns and check if they ignore the correct paths',
        () {
      ignore.add(['test/', 'build/']);
      expect(ignore.ignores('test/'), isTrue);
      expect(ignore.ignores('build/'), isTrue);
      expect(ignore.ignores('src/'), isFalse);
    });

    test('Check if unignored paths are handled correctly', () {
      ignore.add(['test/*', '!test/keep/']);
      expect(ignore.ignores('test/'), isFalse);
      expect(ignore.ignores('test/file.txt'), isTrue);
      expect(ignore.ignores('test/keep/'), isFalse);
      expect(ignore.ignores('test/keep/file.txt'), isFalse);
    });

    test('Filter paths using ignore patterns', () {
      ignore.add(['test/', 'build/']);
      List<String> paths = [
        'test/',
        'build/',
        'src/',
        'lib/',
        'test/ignored.txt',
        'build/ignored.txt'
      ];
      List<String> filteredPaths = ignore.filter(paths);
      expect(filteredPaths, ['src/', 'lib/']);
    });

    test('Check case sensitivity in patterns', () {
      ignore = Ignore(ignoreCase: false);
      ignore.add('test/');
      expect(ignore.ignores('test/'), isTrue);
      expect(ignore.ignores('Test/'), isFalse);
    });

    test('Allow relative paths', () {
      ignore = Ignore(allowRelativePaths: true);
      expect(ignore.ignores('../test/'), isFalse);
      expect(ignore.ignores('/test/'), isFalse);
      ignore = Ignore(allowRelativePaths: false);
      expect(() => ignore.ignores('../test/'), throwsException);
    });

    test('Invalid paths should be handled correctly', () {
      expect(() => ignore.ignores(''), throwsException);
      expect(() => ignore.ignores('/a'), throwsException);
    });

    test('Create filter function and apply it', () {
      ignore.add('test/');
      var filter = ignore.createFilter();
      expect(filter('test/'), isFalse);
      expect(filter('src/'), isTrue);
    });

    test('Test specific paths for ignore and unignore', () {
      ignore.add(['test/*', '!test/keep/']);
      Map<String, bool> result = ignore.test('test/keep/');
      expect(result['ignored'], isFalse);
      expect(result['unignored'], isTrue);
    });

    test('Handle escaped patterns correctly', () {
      ignore.add(r'\!important/');
      expect(ignore.ignores('!important/'), isTrue);
    });
  });
}
