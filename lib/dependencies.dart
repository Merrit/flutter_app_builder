import 'dart:io';

import 'package:logging/logging.dart';

import 'environment.dart';

final _log = Logger('Dependencies');

Future<void> installDependencies() async {
  final env = Environment.instance;

  if (!env.targetingWindows) {
    await _installFlutterDependencies();
  }
}

Future<void> _installFlutterDependencies() async {
  _log.info('Installing dependencies for building Flutter on Linux.');

  final result = await Process.run('bash', [
    '-c',
    'sudo apt-get update && sudo apt-get install -y libgtk-3-dev libx11-dev pkg-config cmake ninja-build libblkid-dev',
  ]);

  if (result.stderr != '') {
    _log.severe('Failed to install Flutter dependencies: ${result.stderr}');
    exit(1);
  }
}
