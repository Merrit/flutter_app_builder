import 'dart:io';

String get tempDirPath {
  String? path = Platform.environment['RUNNER_TEMP'];
  if (path == null) {
    throw Exception('Unable to get temp dir from env var.');
  } else {
    return path;
  }
}

String get workspace {
  String? path = Platform.environment['GITHUB_WORKSPACE'];
  if (path == null) {
    throw Exception('Unable to get workspace from env var.');
  } else {
    return path;
  }
}
