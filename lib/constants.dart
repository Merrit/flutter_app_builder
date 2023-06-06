import 'dart:io';

class BuildPath {
  final String linux;
  final String windows;
  final String macos;
  final String androidBundle;
  final String androidAPK;

  factory BuildPath() {
    if (Platform.environment['GITHUB_EVENT_NAME'] == 'pull_request') {
      return BuildPath._(
        linux: 'build/linux/x64/debug/bundle',
        windows: r'build\windows\runner\Debug',
        macos: 'build/macos/Build/Products/Debug',
        androidBundle: 'build/app/outputs/bundle/debug',
        androidAPK: 'build/app/outputs/flutter-apk',
      );
    } else {
      return BuildPath._(
        linux: 'build/linux/x64/release/bundle',
        windows: r'build\windows\runner\Release',
        macos: 'build/macos/Build/Products/Release',
        androidBundle: 'build/app/outputs/bundle/release',
        androidAPK: 'build/app/outputs/flutter-apk',
      );
    }
  }

  BuildPath._({
    required this.linux,
    required this.windows,
    required this.macos,
    required this.androidBundle,
    required this.androidAPK,
  });
}
