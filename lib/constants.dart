import 'dart:io';

class BuildPath {
  final String linux;
  final String windows;
  final String macos;
  final String androidBundle;
  final String androidAPK;

  factory BuildPath() {
    final bool isPullRequest =
        Platform.environment['GITHUB_EVENT_NAME'] == 'pull_request';

    final appBundleDebugPath = 'build/app/outputs/bundle/debug';
    final appBundleReleasePath = 'build/app/outputs/bundle/release';

    return BuildPath._(
      linux: 'build/linux/x64/release/bundle',
      windows: r'build\windows\x64\runner\Release',
      macos: 'build/macos/Build/Products/Release',
      androidBundle: isPullRequest ? appBundleDebugPath : appBundleReleasePath,
      androidAPK: 'build/app/outputs/flutter-apk',
    );
  }

  BuildPath._({
    required this.linux,
    required this.windows,
    required this.macos,
    required this.androidBundle,
    required this.androidAPK,
  });
}
