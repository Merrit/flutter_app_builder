import 'dart:io';

import 'package:logging/logging.dart';

import 'constants.dart';
import 'environment.dart';

final _log = Logger('Android');

class Android {
  final _env = Environment.instance;

  Future<void> moveAppBundle() async {
    _log.info('Moving appbundle to output directory.');
    final appBundle = File(BuildPath.androidBundle + '/app-release.aab');
    await appBundle.rename(
      _env.outputDir.path + '/${_env.appDisplayName}-Android.aab',
    );
  }

  Future<void> moveApk() async {
    _log.info('Moving apk to output directory.');
    final appBundle = File(BuildPath.androidAPK + '/app-release.apk');
    await appBundle.rename(
      _env.outputDir.path + '/${_env.appDisplayName}-Android.apk',
    );
  }
}
