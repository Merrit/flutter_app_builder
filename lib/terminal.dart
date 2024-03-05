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
      printPubLog();
      exit(1);
    }

    return result.stdout;
  }
}

/// Print the pub log if there is any.
///
/// If there is a log, it should be located at `~/.pub-cache/log/pub_log.txt`.
void printPubLog() {
  final pubLog = File('~/.pub-cache/log/pub_log.txt');
  if (pubLog.existsSync()) {
    log.e('\n\npub log:\n${pubLog.readAsStringSync()}');
  }
}
