import 'dart:io';

bool get isPrerelease {
  /// `GITHUB_WORKFLOW` is the name of the calling workflow in GitHub CI.
  return Platform.environment['GITHUB_WORKFLOW'] == 'Pre-Release';
}

bool get runningInCI => (Platform.environment['CI'] == 'true') ? true : false;

Directory get tempDir {
  Directory tempDir;
  if (runningInCI) {
    tempDir = Directory(Platform.environment['RUNNER_TEMP']!);
  } else {
    tempDir = Directory.systemTemp;
  }

  return tempDir;
}

/// `GITHUB_WORKSPACE` is the base working directory in GitHub CI.
String get workspace => Platform.environment['GITHUB_WORKSPACE'] ?? '';

Future<String> runCommand({required String command}) async {
  String executable;
  List<String> arguments;

  if (Platform.isWindows) {
    executable = 'powershell';
    arguments = [command];
  } else {
    executable = 'bash';
    arguments = ['-c', command];
  }

  print('running on $executable:\n$command');

  final result = await Process.run(executable, arguments);

  if (result.stderr != '') {
    print('\n${result.stderr}');
  }

  return result.stdout;
}
