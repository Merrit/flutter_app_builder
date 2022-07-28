import 'dart:io';

import 'package:archive/archive_io.dart';
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
      await runCommand(command: 'tree');

      print('Tree for temp dir:');
      final String linuxCommand = 'tree $tempDirPath';
      final String windowsCommand = 'tree $tempDirPath /F';
      await runCommand(
        command: Platform.isWindows ? windowsCommand : linuxCommand,
      );
    });
  });
}

Future<String> runCommand({
  required String command,
}) async {
  String executable;
  List<String> arguments;

  if (Platform.isWindows) {
    executable = 'powershell';
    arguments = [command];
  } else {
    executable = 'bash';
    arguments = ['-c', command];
  }

  print('running on $executable: $command');

  final result = await Process.run(executable, arguments);

  if (result.stderr != '') {
    print('\n${result.stderr}');
  }

  if (result.stdout != '') {
    print('\n${result.stdout}');
  }

  return result.stdout;
}
