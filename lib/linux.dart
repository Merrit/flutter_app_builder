import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';

import 'constants.dart';
import 'environment.dart';

class Linux {
  final String _buildPath = BuildPath.linux;
  final Directory _buildDir = Directory(BuildPath.linux);
  final Environment _env = Environment.instance;
  final String portableArchiveName;
  final String portableArchiveFullPath;
  final File portableArchive;

  Linux._({
    required this.portableArchiveName,
    required this.portableArchiveFullPath,
    required this.portableArchive,
  });

  factory Linux() {
    final env = Environment.instance;
    final portableArchiveName = '${env.appDisplayName}-Linux-Portable.tar.gz';
    final portableArchiveFullPath =
        env.outputDir.path + '/$portableArchiveName';

    return Linux._(
      portableArchiveName: portableArchiveName,
      portableArchiveFullPath: portableArchiveFullPath,
      portableArchive: File(portableArchiveFullPath),
    );
  }

  Future<void> package() async {
    await _compressPortable();
    await _createPortableHash();
  }

  Future<void> _compressPortable() async {
    final portableFile = File('$_buildPath/PORTABLE')..createSync();
    await compress(outputFile: portableArchive);
    await portableFile.delete();
  }

  Future<void> _createPortableHash() async {
    final sha256 = await portableArchive.sha256sum();
    final sha256File = File(
      _env.outputDir.path + '/${_env.appDisplayName}-Linux-Portable.sha256sum',
    );
    await sha256File.writeAsString(sha256);
  }

  Future<void> compress({
    File? inputFile,
    Directory? inputDirectory,
    required File outputFile,
  }) async {
    assert(inputDirectory != null || inputFile != null);

    List<int>? bytes;

    if (inputDirectory != null) {
      final archive = createArchiveFromDirectory(_buildDir);
      final tarData = TarEncoder().encode(archive);
      bytes = GZipEncoder().encode(tarData);
    } else {
      bytes = GZipEncoder().encode(inputFile!.readAsBytesSync());
    }

    await outputFile.create();
    await outputFile.writeAsBytes(bytes!);
  }
}

extension FileHelper on File {
  Future<String> sha256sum() async {
    final bytes = await readAsBytes();
    return sha256.convert(bytes).toString();
  }
}
