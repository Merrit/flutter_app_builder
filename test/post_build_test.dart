import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:test/test.dart';

import 'common.dart';

void main() {
  final bool isPrerelease = (Platform.environment['prerelease'] == 'true');

  final githubAction = Platform.environment['GITHUB_ACTION'];
  print('githubAction: $githubAction');

  group('linux', () {
    if (!Platform.isLinux) return;

    final linuxPortableArchive = File(
      '$workspace/artifacts/linux-artifacts/IncredibleApp-Linux-Portable.tar.gz',
    );

    test('portable exists', () {
      expect(linuxPortableArchive.existsSync(), true);
    });

    test('portable has BUILD file', () async {
      final inPath = linuxPortableArchive.path;
      final outPath = '$tempDirPath/linuxPortable';
      await extractFileToDisk(inPath, outPath);
      final buildFile = File('$outPath/BUILD');
      expect(buildFile.existsSync(), isPrerelease ? true : false);
    });
  });

  group('windows', () {
    if (!Platform.isWindows) return;

    final windowsPortableArchive = File(
      '$workspace\\artifacts\\windows-artifacts\\IncredibleApp-Windows-Portable.zip',
    );

    test('portable exists', () {
      expect(windowsPortableArchive.existsSync(), true);
    });

    test('portable has BUILD file', () async {
      final inPath = windowsPortableArchive.path;
      final outPath = '$tempDirPath\\windowsPortable';
      await extractFileToDisk(inPath, outPath);
      final buildFile = File('$outPath\\BUILD');
      expect(buildFile.existsSync(), isPrerelease ? true : false);
    });
  });
}
