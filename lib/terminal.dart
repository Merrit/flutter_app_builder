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
      await printPubLog();
      exit(1);
    }

    return result.stdout;
  }
}

/// Print the pub log if there is any.
///
/// If there is a log, it should be located at `~/.pub-cache/log/pub_log.txt`.
Future<void> printPubLog() async {
  log.i('Printing pub log');

  final String? home = Platform.environment['HOME'];
  if (home == null) {
    log.e('HOME environment variable is not set');
    return;
  }

  final pubLog = File('$home/.pub-cache/log/pub_log.txt');
  final exists = await pubLog.exists();

  if (!exists) {
    log.i('pub log does not exist');
    return;
  }

  log.e('\n\npub log:\n${pubLog.readAsStringSync()}');
}
