import 'dart:io';

import 'package:args/args.dart';
import 'package:pub_semver/pub_semver.dart';

import 'logging_manager.dart';
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

  final String msixIdentityName;
  final String? msixPublisher;

  /// Path to the icon to supply to the msix installer.
  ///
  /// Can be either png or ico.
  final String msixIconPath;

  /// Declared permissions for the Microsoft Store.
  final String msixCapabilities;

  final Version version;

  final List<Target> targets;
  final Directory outputDir;
  final Directory projectRoot;

  final bool runningInGithubCI;

  const Environment._({
    required this.appName,
    required this.appDisplayName,
    required this.author,
    required this.identifier,
    required this.msixIdentityName,
    required this.msixPublisher,
    required this.msixIconPath,
    required this.msixCapabilities,
    required this.version,
    required this.targets,
    required this.outputDir,
    required this.projectRoot,
    required this.runningInGithubCI,
  });

  static late final Environment instance;

  static Future<Environment> initialize({
    required ArgResults argResults,
    required Pubspec pubspec,
    required List<Target> targets,
  }) async {
    final Map<String, String> env = Platform.environment;

    final bool runningInGitubCI = env['GITHUB_ACTIONS'] == 'true';
    log.v('Running in GitHub workflow: $runningInGitubCI');

    instance = Environment._(
      appName: pubspec.name,
      appDisplayName:
          argResults['app-display-name'] ?? pubspec.appDisplayName ?? '',
      author: argResults['author'] ?? pubspec.author ?? '',
      identifier: argResults['identifier'] ?? pubspec.identifier ?? '',
      msixIdentityName:
          argResults['msix-identity-name'] ?? pubspec.msixIdentityName ?? '',
      msixPublisher: argResults['msix-publisher'] ?? pubspec.msixPublisher,
      msixIconPath: argResults['msix-icon-path'] ?? pubspec.msixIconPath ?? '',
      msixCapabilities:
          argResults['msix-capabilities'] ?? pubspec.msixCapabilities ?? '',
      version: pubspec.version,
      targets: targets,
      outputDir: Directory('output')..createSync(),
      projectRoot: Directory.current,
      runningInGithubCI: runningInGitubCI,
    );

    return instance;
  }

  bool get targetingLinux => targets.contains(Target.linux);
  bool get targetingWindows => targets.contains(Target.windows);
  bool get targetingAndroid => targets.contains(Target.android);
}

enum Target {
  linux,
  windows,
  android,
}

const targetHashMap = {
  'linux': Target.linux,
  'windows': Target.windows,
  'android': Target.android,
};
