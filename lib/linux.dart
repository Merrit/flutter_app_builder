import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_app_builder/terminal.dart';

import 'constants.dart';
import 'environment.dart';
import 'logging_manager.dart';

class Linux {
  final String _buildPath = BuildPath.linux;
  final Environment _env = Environment.instance;
  final String portableArchiveName;
  final File portableArchiveInOutput;

  Linux._({
    required this.portableArchiveName,
    required this.portableArchiveInOutput,
  });

  factory Linux() {
    final env = Environment.instance;
    final portableArchiveName = '${env.appDisplayName}-Linux-Portable.tar.gz';

    return Linux._(
      portableArchiveName: portableArchiveName,
      portableArchiveInOutput: File(
        env.outputDir.path + '/$portableArchiveName',
      ),
    );
  }

  Future<void> package() async {
    log.v('Packaging Linux build.');
    await _addBuildInfo();
    await _addReadme();
    await _compressPortable();
    await _createPortableHash();
  }

  /// Add info about when this build occurred, only for preleases.
  Future<void> _addBuildInfo() async {
    if (Platform.environment['GITHUB_WORKFLOW'] != 'Pre-Release') return;

    final buildFile = File('$_buildPath/BUILD');
    await buildFile.writeAsString(DateTime.now().toUtc().toString());
  }

  Future<void> _addReadme() async {
    final readme = File('README.md');
    final exists = await readme.exists();
    if (!exists) return;

    await readme.copy('$_buildPath/README.md');
  }

  // Using bash commands because the `archive` package doesn't seem to
  // have a proper way to add a directory's contents as an archive.
  Future<void> _compressPortable() async {
    final portableFile = File('$_buildPath/PORTABLE')..createSync();
    final result = await Terminal.runCommand(
      command: '''
cd $_buildPath
tar czf "$portableArchiveName" *
mv *.tar.gz "${_env.outputDir.absolute.path}/$portableArchiveName"
cd ${_env.projectRoot.absolute.path}''',
    );
    print(result);
    await portableFile.delete();
  }

  Future<void> _createPortableHash() async {
    final String sha256 = await portableArchiveInOutput.sha256sum();
    log.v('Linux portable sha256: $sha256');
    final sha256File = File(
      _env.outputDir.path + '/${_env.appDisplayName}-Linux-Portable.sha256sum',
    );
    await sha256File.writeAsString(sha256);
  }
}

extension FileHelper on File {
  Future<String> sha256sum() async {
    final bytes = await readAsBytes();
    return sha256.convert(bytes).toString();
  }
}
