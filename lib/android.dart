import 'dart:io';

import 'constants.dart';
import 'environment.dart';
import 'logging_manager.dart';

class Android {
  final _env = Environment.instance;
  final BuildPath _buildPath;

  Android(this._buildPath);

  Future<void> moveAppBundle() async {
    log.v('Moving appbundle to output directory.');
    bool isReleaseBuild =
        Platform.environment['GITHUB_EVENT_NAME'] != 'pull_request';
    String buildType = isReleaseBuild ? 'release' : 'debug';
    final appBundle = File('${_buildPath.androidBundle}/app-$buildType.aab');
    await appBundle.rename(
      '${_env.outputDir.path}/${_env.appDisplayName}-Android.aab',
    );
  }

  Future<void> moveApk() async {
    log.v('Moving apk to output directory.');
    bool isReleaseBuild =
        Platform.environment['GITHUB_EVENT_NAME'] != 'pull_request';
    String buildType = isReleaseBuild ? 'release' : 'debug';
    final appBundle = File('${_buildPath.androidAPK}/app-$buildType.apk');
    await appBundle.rename(
      '${_env.outputDir.path}/${_env.appDisplayName}-Android.apk',
    );
  }
}
