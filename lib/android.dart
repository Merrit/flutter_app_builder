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
    final appBundle = File('${_buildPath.androidBundle}/app-release.aab');
    await appBundle.rename(
      '${_env.outputDir.path}/${_env.appDisplayName}-Android.aab',
    );
  }

  Future<void> moveApk() async {
    log.v('Moving apk to output directory.');
    final appBundle = File('${_buildPath.androidAPK}/app-release.apk');
    await appBundle.rename(
      '${_env.outputDir.path}/${_env.appDisplayName}-Android.apk',
    );
  }
}
