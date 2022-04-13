import 'dart:io';

import 'package:logging/logging.dart';

import 'environment.dart';

final _log = Logger('Terminal');

abstract class Terminal {
  static Future<String> runCommand({
    required String command,
  }) async {
    String executable;
    List<String> arguments;

    if (Environment.instance.targetingWindows) {
      executable = 'powershell';
      arguments = [command];
    } else {
      executable = 'bash';
      arguments = ['-c', command];
    }

    _log.info('running on $executable: $command');

    final result = await Process.run(executable, arguments);

    if (result.stderr != '') throw Exception(result.stderr);

    return result.stdout;
  }
}
