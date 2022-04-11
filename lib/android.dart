import 'dart:io';

import 'constants.dart';
import 'environment.dart';

class Android {
  final _env = Environment.instance;

  Future<void> moveAppBundle() async {
    final appBundle = File(BuildPath.androidBundle + '/app-release.aab');
    await appBundle.rename(
      _env.outputDir.path + '/${_env.appDisplayName}-Android.aab',
    );
  }

  Future<void> moveApk() async {
    final appBundle = File(BuildPath.androidAPK + '/app-release.apk');
    await appBundle.rename(
      _env.outputDir.path + '/${_env.appDisplayName}-Android.apk',
    );
  }
}
