import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_app_builder/terminal.dart';
import 'package:test/test.dart';

import 'common.dart';

void main() {
  final bool isPrerelease = (Platform.environment['prerelease'] == 'true');
  print('isPrerelease: $isPrerelease');

  group('Portable:', () {
    final String linuxPortableArchivePath =
        '$workspace/artifacts/linux-artifacts/IncredibleApp-Linux-Portable.tar.gz';
    final String windowsPortableArchivePath =
        '$workspace\\artifacts\\windows-artifacts\\IncredibleApp-Windows-Portable.zip';

    final File portableArchive = File(
      Platform.isLinux ? linuxPortableArchivePath : windowsPortableArchivePath,
    );

    test('archive exists', () async {
      final bool exists = await portableArchive.exists();
      expect(exists, true);
    });

    test(
      'has BUILD file',
      () async {
        final inPath = portableArchive.path;
        final outPath = '$tempDirPath${Platform.pathSeparator}portable';
        await extractFileToDisk(inPath, outPath);
        final buildFile = File('$outPath${Platform.pathSeparator}BUILD');
        final exists = await buildFile.exists();
        expect(exists, isPrerelease ? true : false);
      },
      // Longer timeout required for Linux.
      timeout: Platform.isLinux ? Timeout(Duration(minutes: 2)) : null,
    );

    test('debug', () async {
      print('Tree for current dir:');
      await Terminal.runCommand(command: 'tree');

      print('Tree for temp dir:');
      await Terminal.runCommand(command: 'cd $tempDirPath && tree');
    });
  });
}
