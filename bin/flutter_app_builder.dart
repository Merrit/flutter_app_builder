import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_app_builder/builder.dart';
import 'package:flutter_app_builder/pubspec.dart';
import 'package:flutter_app_builder/dependencies.dart';
import 'package:flutter_app_builder/environment.dart';
import 'package:flutter_app_builder/terminal.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('app-display-name')
    ..addOption('author')
    ..addOption('identifier')
    ..addMultiOption(
      'platforms',
      allowed: ['linux', 'windows', 'android'],
    );

  final ArgResults argResults = parser.parse(arguments);
  final targets = parser.parsePlatforms(
    argResults['platforms'] as List<String>,
  );

  final pubspecFile = File('pubspec.yaml');
  final pubspec = Pubspec(pubspecString: await pubspecFile.readAsString());

  final environment = await Environment.initialize(
    argResults: argResults,
    pubspec: pubspec,
    targets: targets,
  );

  if (environment.runningInGithubCI) {
    await installDependencies();
    await enableFlutterDesktop();
    await getPackages();
    verifyPubspecVersion();
  }

  await Builder().run();
  await environment.gitHub?.uploadArtifactsToDraftRelease();
}

Future<void> enableFlutterDesktop() async {
  await Terminal.runCommand(command: '''
flutter config --enable-linux-desktop
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop''');
}

Future<void> getPackages() async {
  await Terminal.runCommand(command: '''
flutter upgrade
flutter pub get''');
}

/// Verify pubspec version has been updated to match tag for release.
void verifyPubspecVersion() {
  final env = Environment.instance;

  final githubTagVersion = env.gitHub?.refName.substring(1);
  final pubspecVersion =
      '${env.version.major}.${env.version.minor}.${env.version.patch}';

  if (githubTagVersion != pubspecVersion) {
    throw Exception('''
Pubspec version does not match GitHub tag.
Did you forget to bump the version in Pubspec?
Pubspec version is: $pubspecVersion
GitHub tag is: ${env.gitHub?.refName}''');
  }
}

extension on ArgParser {
  List<Target> parsePlatforms(List<String> platforms) {
    final targets = <Target>[];

    for (var platform in platforms) {
      final Target? target = targetHashMap[platform];
      if (target == null) continue;
      targets.add(target);
      // Environment.targets.add(target);
    }

    return targets;
  }
}
