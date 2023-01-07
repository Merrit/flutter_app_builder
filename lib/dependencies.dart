import 'dart:io';

import 'environment.dart';
import 'logging_manager.dart';

Future<void> installDependencies() async {
  final env = Environment.instance;

  if (!env.targetingWindows) {
    await _installFlutterDependencies();
  }
}

Future<void> _installFlutterDependencies() async {
  log.v('Installing dependencies for building Flutter on Linux.');

  final result = await Process.run('bash', [
    '-c',
    'sudo apt-get update && sudo apt-get install -y libgtk-3-dev libx11-dev pkg-config cmake ninja-build libblkid-dev',
  ]);

  if (result.stderr != '') {
    log.e('Failed to install Flutter dependencies: ${result.stderr}');
    exit(1);
  }
}
