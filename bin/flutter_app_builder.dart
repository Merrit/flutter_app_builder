import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_app_builder/builder.dart';
import 'package:flutter_app_builder/constants.dart';
import 'package:flutter_app_builder/github.dart';
import 'package:flutter_app_builder/logging_manager.dart';
import 'package:flutter_app_builder/pubspec.dart';
import 'package:flutter_app_builder/dependencies.dart';
import 'package:flutter_app_builder/environment.dart';
import 'package:flutter_app_builder/terminal.dart';

Future<void> main(List<String> arguments) async {
  print('Initializing Flutter App Builder.');

  final parser = ArgParser()
    ..addOption('app-display-name')
    ..addOption('author')
    ..addOption('identifier')
    ..addOption('msix-identity-name')
    ..addOption('msix-publisher')
    ..addOption('msix-icon-path')
    ..addOption('msix-capabilities')
    ..addMultiOption(
      'platforms',
      allowed: ['linux', 'windows', 'android'],
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
    );

  final ArgResults argResults = parser.parse(arguments);

  await LoggingManager.initialize(verbose: argResults['verbose']);

  if (!argResults.wasParsed('platforms')) {
    log.e('No target platforms were specified.');
    exit(1);
  }

  final BuildPath buildPath = BuildPath();

  final targets = parser.parsePlatforms(
    argResults['platforms'] as List<String>,
  );
  log.v('Building for target platforms: $targets');

  final pubspecFile = File('pubspec.yaml');
  final pubspecString = pubspecFile.readAsStringSync();
  final pubspec = Pubspec(pubspecString: pubspecString);

  await cleanOutputDirectory();

  final environment = await Environment.initialize(
    argResults: argResults,
    pubspec: pubspec,
    targets: targets,
  );

  if (environment.runningInGithubCI) {
    GitHub.initialize();
    await installDependencies();
    await getPackages();
    verifyPubspecVersion();
  }

  await Builder().run(
    buildPath: buildPath,
    runBuildRunner: pubspecString.contains('build_runner'),
  );

  if (environment.runningInGithubCI) {
    await GitHub.instance.uploadArtifactsToDraftRelease();
  }

  log.v('Finished building and packaging Flutter app.');
}

Future<void> cleanOutputDirectory() async {
  final output = Directory('output');
  if (output.existsSync()) {
    log.v('Cleaning output directory.');
    await output.delete(recursive: true);
  }
}

Future<void> getPackages() async {
  log.v('flutter pub get');
  await Terminal.runCommand(command: 'flutter pub get');
}

/// Verify pubspec version has been updated to match tag for release.
void verifyPubspecVersion() {
  final env = Environment.instance;
  final github = GitHub.instance;

  if (github.eventName != 'push') return;

  /// If the tag doesn't begin with `v`, we don't need to verify.
  if (github.refName[0] != 'v') return;

  final githubTagVersion = github.refName.substring(1);
  final pubspecVersion =
      '${env.version.major}.${env.version.minor}.${env.version.patch}';

  if (githubTagVersion != pubspecVersion) {
    log.e('''
Pubspec version does not match GitHub tag.
Did you forget to bump the version in Pubspec?
Pubspec version is: $pubspecVersion
GitHub tag is: ${github.refName}''');
    exit(1);
  }
}

extension on ArgParser {
  List<Target> parsePlatforms(List<String> platforms) {
    final targets = <Target>[];

    for (var platform in platforms) {
      final Target? target = targetHashMap[platform];
      if (target == null) continue;
      targets.add(target);
    }

    return targets;
  }
}
