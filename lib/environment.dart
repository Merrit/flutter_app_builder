import 'dart:io';

import 'package:args/args.dart';
import 'package:pub_semver/pub_semver.dart';

import 'github.dart';
import 'pubspec.dart';

class Environment {
  /// Identifying name, eg `app_name`.
  final String appName;

  /// Pretty application name, eg `App Name`.
  final String appDisplayName;

  /// The company, organization or person who created the app, eg `Google`.
  final String author;

  /// Reverse domain identifier, eg `com.example.AppName`.
  final String identifier;

  final Version version;

  final List<Target> targets;
  final Directory outputDir;

  final bool runningInGithubCI;
  final GitHub? gitHub;

  const Environment._({
    required this.appName,
    required this.appDisplayName,
    required this.author,
    required this.identifier,
    required this.version,
    required this.targets,
    required this.outputDir,
    required this.runningInGithubCI,
    required this.gitHub,
  });

  static late final Environment instance;

  static Future<Environment> initialize({
    required ArgResults argResults,
    required Pubspec pubspec,
    required List<Target> targets,
  }) async {
    final Map<String, String> env = Platform.environment;

    final bool runningInGitubCI = env['GITHUB_ACTIONS'] == 'true';

    instance = Environment._(
      appName: pubspec.name,
      appDisplayName:
          argResults['app-display-name'] ?? pubspec.appDisplayName ?? '',
      author: argResults['author'] ?? pubspec.author ?? '',
      identifier: argResults['identifier'] ?? pubspec.identifier ?? '',
      version: pubspec.version,
      targets: targets,
      outputDir: Directory('output')..createSync(),
      runningInGithubCI: runningInGitubCI,
      gitHub: runningInGitubCI ? GitHub.initialize() : null,
    );

    return instance;
  }

  bool get targetingLinux => targets.contains(Target.linux);
  bool get targetingWindows => targets.contains(Target.windows);
  bool get targetingAndroid => targets.contains(Target.androidBundle);
}

enum Target {
  linux,
  windows,
  androidBundle,
  androidApk,
}

const targetHashMap = {
  'linux': Target.linux,
  'windows': Target.windows,
  'appbundle': Target.androidBundle,
  'apk': Target.androidApk,
};
