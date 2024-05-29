import 'package:buildr_studio/utils/git_ignore_checker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GitIgnoreChecker', () {
    test('should return true if path matches a literal rule', () {
      const gitIgnoreContent = 'file.txt';
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'), isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'dir/file.txt'),
          isTrue);
    });

    test('should return true if path matches a wildcard rule', () {
      const gitIgnoreContent = '*.txt';
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, '/file.txt'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, '/dir/file.txt'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.jpg'),
          isFalse);
    });

    test(
        'isPathIgnored should return true if path matches a directory rule with a trailing slash',
        () {
      const gitIgnoreContent = 'build/';
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'build/output.txt'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, '/build/'), isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'abc/build/output.txt'),
          isTrue);
    });

    test(
        'isPathIgnored should return true if path matches an absolute directory rule with a trailing slash',
        () {
      const gitIgnoreContent = '/build/';
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, '/build'), isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, '/build/output.txt'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'abc/build/output.txt'),
          isFalse);
    });

    test(
        'isPathIgnored should return false for a path that does not match any rule',
        () {
      const gitIgnoreContent = 'build/';
      const path = 'lib/main.dart';
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, path), isFalse);
    });

    test('should return false if path matches a negated rule', () {
      const gitIgnoreContent = '''
        *.txt
        !important.txt
      ''';
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'important.txt'),
          isFalse);
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'), isTrue);
    });

    test('should handle errors gracefully', () {
      expect(GitIgnoreChecker.isPathIgnored('invalid content', 'file.txt'),
          isFalse);
    });

    test('should ignore .class files', () {
      const gitIgnoreContent = '*.class';
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'MyClass.class'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'package/MyClass.class'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'MyClass.java'),
          isFalse);
    });

    test('should ignore .log files', () {
      const gitIgnoreContent = '*.log';
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'app.log'), isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'logs/app.log'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'app.txt'), isFalse);
    });

    test('should ignore .pyc files', () {
      const gitIgnoreContent = '*.pyc';
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'module.pyc'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'package/module.pyc'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'module.py'),
          isFalse);
    });

    test('should ignore .swp files', () {
      const gitIgnoreContent = '*.swp';
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.swp'), isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'folder/file.swp'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'),
          isFalse);
    });

    test('should ignore files that matches the name', () {
      const gitIgnoreContent = 'DS_Store';
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'DS_Store'), isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'folder/DS_Store'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'),
          isFalse);
    });

    test('should ignore .atom/ directory', () {
      const gitIgnoreContent = '.atom/';
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, '.atom/config.cson'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.atom/packages/my-package'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'),
          isFalse);
    });

    test('should ignore .buildlog/ directory', () {
      const gitIgnoreContent = '.buildlog/';
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.buildlog/output.log'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, '.buildlog/debug/'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'),
          isFalse);
    });

    test('should ignore .history directory', () {
      const gitIgnoreContent = '.history';
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.history/file_changes.txt'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.history/folder/file.txt'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'),
          isFalse);
    });

    test('should ignore .svn/ directory', () {
      const gitIgnoreContent = '.svn/';
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, '.svn/entries'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, '.svn/wc.db'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'),
          isFalse);
    });

    test('should ignore migrate_working_dir/ directory', () {
      const gitIgnoreContent = 'migrate_working_dir/';
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'migrate_working_dir/changes.txt'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'migrate_working_dir/scripts/'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'),
          isFalse);
    });

    test('should ignore *.iml, *.ipr, and *.iws files', () {
      const gitIgnoreContent = '''
    *.iml
    *.ipr
    *.iws
  ''';
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'project.iml'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'project.ipr'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'project.iws'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'project.txt'),
          isFalse);
    });

    test('should ignore .idea/ directory', () {
      const gitIgnoreContent = '.idea/';
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.idea/workspace.xml'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, '.idea/modules.xml'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'file.txt'),
          isFalse);
    });

    test('should ignore **/doc/api/ directory', () {
      const gitIgnoreContent = '**/doc/api/';
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'lib/doc/api/index.html'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'packages/my_package/doc/api/reference.html'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'lib/main.dart'),
          isFalse);
    });

    test('should ignore .dart_tool/ directory', () {
      const gitIgnoreContent = '.dart_tool/';
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.dart_tool/package_config.json'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.dart_tool/flutter_build/'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'lib/main.dart'),
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
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, '.flutter-plugins'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.flutter-plugins-dependencies'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'pubspec.yaml'),
          isFalse);
    });

    test('should ignore .pub-cache/ directory', () {
      const gitIgnoreContent = '.pub-cache/';
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.pub-cache/hosted/pub.dartlang.org'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '.pub-cache/packages/'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'pubspec.yaml'),
          isFalse);
    });

    test('should ignore /build/ directory', () {
      const gitIgnoreContent = '/build/';
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '/build/outputs/apk/release/app-release.apk'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '/build/ios/Runner.app'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'lib/main.dart'),
          isFalse);
    });

    test('should ignore app.*.symbols files', () {
      const gitIgnoreContent = 'app.*.symbols';
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'app.1234.symbols'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'app.abcd.symbols'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'app.txt'), isFalse);
    });

    test('should ignore app.*.map.json files', () {
      const gitIgnoreContent = 'app.*.map.json';
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'app.1234.map.json'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'app.abcd.map.json'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'app.map.json'),
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
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '/android/app/debug/app-debug.apk'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '/android/app/profile/app-profile.apk'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '/android/app/release/app-release.apk'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '/android/build.gradle'),
          isFalse);
    });

    test('should ignore /.venv/ directory', () {
      const gitIgnoreContent = '/.venv/';
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '/.venv/bin/activate'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, '/.venv/lib/python3.9/site-packages'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'lib/main.dart'),
          isFalse);
    });

    test('should ignore **/failures/*.png files', () {
      const gitIgnoreContent = '**/failures/*.png';
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'test/failures/test_failure.png'),
          isTrue);
      expect(
          GitIgnoreChecker.isPathIgnored(
              gitIgnoreContent, 'integration_test/failures/screenshot.png'),
          isTrue);
      expect(GitIgnoreChecker.isPathIgnored(gitIgnoreContent, 'lib/main.dart'),
          isFalse);
    });
  });
}
