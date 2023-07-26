import 'dart:io';

import 'android.dart';
import 'constants.dart';
import 'environment.dart';
import 'linux.dart';
import 'logging_manager.dart';
import 'terminal.dart';
import 'windows.dart';

// TODO: De-duplicate a bunch of this stuff. Probably should be all in this
// Builder class.. Set variables like path once at the beginning that steps can
// refer to without having to constantly check the platform.

class Builder {
  Future<void> run({
    required BuildPath buildPath,

    /// Whether or not to run the build_runner command.
    required bool runBuildRunner,
  }) async {
    if (runBuildRunner) {
      await _runBuildRunner();
    }

    for (var target in Environment.instance.targets) {
      switch (target) {
        case Target.linux:
          await _buildPlatform('linux');
          await Linux(buildPath: buildPath).package();
          break;
        case Target.windows:
          final windows = Windows(buildPath: buildPath);
          await _buildPlatform('windows');
          await windows.package();
          break;
        case Target.android:
          await _buildPlatform('appbundle');
          final android = Android(buildPath);
          await android.moveAppBundle();
          await _buildPlatform('apk');
          await android.moveApk();
          break;
      }
    }

    await _validateArchiveFilenames();
  }

  /// Runs the build_runner command.
  ///
  /// This is used to generate the code for things like freezed.
  Future<void> _runBuildRunner() async {
    log.i('Running build_runner');

    await Terminal.runCommand(
      command:
          'flutter pub run build_runner build --delete-conflicting-outputs',
    );
  }

  Future<String> _buildPlatform(String platform) async {
    log.i('Running build for $platform');

    bool buildReleaseVersion =
        Platform.environment['GITHUB_EVENT_NAME'] != 'pull_request';

    final bool buildingAndroid = platform == 'appbundle' || platform == 'apk';

    String buildType;
    if (buildingAndroid) {
      // Android builds can't access the keystore in GitHub PR CI runs, so
      // we have to use debug builds.
      buildType = buildReleaseVersion ? 'release' : 'debug';
    } else {
      buildType = 'release';
    }

    return await Terminal.runCommand(
      command: 'flutter build -v $platform --$buildType',
    );
  }

  Future<void> _validateArchiveFilenames() async {
    final separator = (Platform.isWindows) ? '\\' : '/';

    for (var file in Environment.instance.outputDir.listSync()) {
      final name = file.path.split(separator).last;
      final validatedName = name.replaceAll(' ', '');
      await file.rename(
        Environment.instance.outputDir.absolute.path +
            separator +
            validatedName,
      );
    }
  }
}
