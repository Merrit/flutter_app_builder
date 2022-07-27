import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:test/test.dart';

import 'common.dart';

void main() {
  group('linux', () {
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
      expect(buildFile.existsSync(), true);
    });
  });

  group('windows', () {
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
      expect(buildFile.existsSync(), true);
    });
  });
}
