import 'package:buildr_studio/utils/git_ignore_checker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GitIgnoreChecker', () {
    late GitIgnoreChecker gitIgnoreChecker;

    setUp(() {
      gitIgnoreChecker = GitIgnoreChecker();
    });

    test('should return true if path matches a literal rule', () {
      const gitIgnoreContent = 'file.txt';
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'), isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'dir/file.txt'),
          isTrue);
    });

    test('should return true if path matches a wildcard rule', () {
      const gitIgnoreContent = '*.txt';
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, '/file.txt'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, '/dir/file.txt'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.jpg'),
          isFalse);
    });

    test(
        'isPathIgnored should return true if path matches a directory rule with a trailing slash',
        () {
      const gitIgnoreContent = 'build/';
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'build/output.txt'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, '/build/'), isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'abc/build/output.txt'),
          isTrue);
    });

    test(
        'isPathIgnored should return true if path matches an absolute directory rule with a trailing slash',
        () {
      const gitIgnoreContent = '/build/';
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, '/build'), isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, '/build/output.txt'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'abc/build/output.txt'),
          isFalse);
    });

    test(
        'isPathIgnored should return false for a path that does not match any rule',
        () {
      const gitIgnoreContent = 'build/';
      const path = 'lib/main.dart';
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, path), isFalse);
    });

    test('should return false if path matches a negated rule', () {
      const gitIgnoreContent = '''
        *.txt
        !important.txt
      ''';
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'important.txt'),
          isFalse);
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'), isTrue);
    });

    test('should handle errors gracefully', () {
      expect(gitIgnoreChecker.isPathIgnored('invalid content', 'file.txt'),
          isFalse);
    });

    test('should ignore .class files', () {
      const gitIgnoreContent = '*.class';
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'MyClass.class'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'package/MyClass.class'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'MyClass.java'),
          isFalse);
    });

    test('should ignore .log files', () {
      const gitIgnoreContent = '*.log';
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'app.log'), isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'logs/app.log'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'app.txt'), isFalse);
    });

    test('should ignore .pyc files', () {
      const gitIgnoreContent = '*.pyc';
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'module.pyc'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'package/module.pyc'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'module.py'),
          isFalse);
    });

    test('should ignore .swp files', () {
      const gitIgnoreContent = '*.swp';
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.swp'), isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'folder/file.swp'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'),
          isFalse);
    });

    test('should ignore files that matches the name', () {
      const gitIgnoreContent = 'DS_Store';
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'DS_Store'), isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'folder/DS_Store'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'),
          isFalse);
    });

    test('should ignore .atom/ directory', () {
      const gitIgnoreContent = '.atom/';
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, '.atom/config.cson'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.atom/packages/my-package'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'),
          isFalse);
    });

    test('should ignore .buildlog/ directory', () {
      const gitIgnoreContent = '.buildlog/';
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.buildlog/output.log'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, '.buildlog/debug/'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'),
          isFalse);
    });

    test('should ignore .history directory', () {
      const gitIgnoreContent = '.history';
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.history/file_changes.txt'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.history/folder/file.txt'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'),
          isFalse);
    });

    test('should ignore .svn/ directory', () {
      const gitIgnoreContent = '.svn/';
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, '.svn/entries'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, '.svn/wc.db'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'),
          isFalse);
    });

    test('should ignore migrate_working_dir/ directory', () {
      const gitIgnoreContent = 'migrate_working_dir/';
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'migrate_working_dir/changes.txt'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'migrate_working_dir/scripts/'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'),
          isFalse);
    });

    test('should ignore *.iml, *.ipr, and *.iws files', () {
      const gitIgnoreContent = '''
    *.iml
    *.ipr
    *.iws
  ''';
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'project.iml'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'project.ipr'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'project.iws'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'project.txt'),
          isFalse);
    });

    test('should ignore .idea/ directory', () {
      const gitIgnoreContent = '.idea/';
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.idea/workspace.xml'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, '.idea/modules.xml'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'),
          isFalse);
    });

    test('should ignore **/doc/api/ directory', () {
      const gitIgnoreContent = '**/doc/api/';
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'lib/doc/api/index.html'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'packages/my_package/doc/api/reference.html'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'lib/main.dart'),
          isFalse);
    });

    test('should ignore .dart_tool/ directory', () {
      const gitIgnoreContent = '.dart_tool/';
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.dart_tool/package_config.json'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.dart_tool/flutter_build/'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'lib/main.dart'),
          isFalse);
    });

    test(
        'should ignore .flutter-plugins and .flutter-plugins-dependencies files',
        () {
      const gitIgnoreContent = '''
    .flutter-plugins
    .flutter-plugins-dependencies
  ''';
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, '.flutter-plugins'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.flutter-plugins-dependencies'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'pubspec.yaml'),
          isFalse);
    });

    test('should ignore .pub-cache/ directory', () {
      const gitIgnoreContent = '.pub-cache/';
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.pub-cache/hosted/pub.dartlang.org'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.pub-cache/packages/'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'pubspec.yaml'),
          isFalse);
    });

    test('should ignore /build/ directory', () {
      const gitIgnoreContent = '/build/';
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '/build/outputs/apk/release/app-release.apk'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '/build/ios/Runner.app'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'lib/main.dart'),
          isFalse);
    });

    test('should ignore app.*.symbols files', () {
      const gitIgnoreContent = 'app.*.symbols';
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'app.1234.symbols'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'app.abcd.symbols'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'app.txt'), isFalse);
    });

    test('should ignore app.*.map.json files', () {
      const gitIgnoreContent = 'app.*.map.json';
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'app.1234.map.json'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'app.abcd.map.json'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'app.map.json'),
          isFalse);
    });

    test(
        'should ignore /android/app/debug, /android/app/profile, and /android/app/release directories',
        () {
      const gitIgnoreContent = '''
    /android/app/debug
    /android/app/profile
    /android/app/release
  ''';
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '/android/app/debug/app-debug.apk'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '/android/app/profile/app-profile.apk'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '/android/app/release/app-release.apk'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '/android/build.gradle'),
          isFalse);
    });

    test('should ignore /.venv/ directory', () {
      const gitIgnoreContent = '/.venv/';
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '/.venv/bin/activate'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '/.venv/lib/python3.9/site-packages'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'lib/main.dart'),
          isFalse);
    });

    test('should ignore **/failures/*.png files', () {
      const gitIgnoreContent = '**/failures/*.png';
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'test/failures/test_failure.png'),
          isTrue);
      expect(
          gitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'integration_test/failures/screenshot.png'),
          isTrue);
      expect(gitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'lib/main.dart'),
          isFalse);
    });
  });
}
