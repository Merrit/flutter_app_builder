import 'dart:io';

import 'environment.dart';
import 'logging_manager.dart';

abstract class Terminal {
  static Future<String> runCommand({
    required String command,
  }) async {
    String executable;
    List<String> arguments;

    if (Environment.instance.targetingWindows) {
      executable = 'powershell';
      arguments = ['-NoProfile', '-NonInteractive', command];
    } else {
      executable = 'bash';
      arguments = ['-c', command];
    }

    log.i('running on $executable:\n$command');

    final result = await Process.run(executable, arguments);

    if (result.stderr != '') {
      log.e('\n${result.stderr}');
      exit(1);
    }

    return result.stdout;
  }
}
