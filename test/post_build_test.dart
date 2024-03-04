import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:test/test.dart';

import 'common.dart';

const String linuxPortableArchiveName = 'IncredibleApp-Linux-Portable.tar.gz';
const String windowsPortableArchiveName = 'IncredibleApp-Windows-Portable.zip';

late final Directory tempDirectory;
late final String tempDirPath;

Future<void> main() async {
  tempDirPath = tempDir.path;
  await runBuild();

  group('Portable:', () {
    String linuxPortableArchivePath;
    linuxPortableArchivePath = runningInCI
        ? '$workspace/artifacts/linux-artifacts/$linuxPortableArchiveName'
        : 'example/output/$linuxPortableArchiveName'; // Local

    String windowsPortableArchivePath;
    windowsPortableArchivePath = runningInCI
        ? '$workspace\\artifacts\\windows-artifacts\\$windowsPortableArchiveName'
        : 'example\\output\\$windowsPortableArchiveName'; // Local

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
  });
}

/// Build artifacts locally, when not running in CI.
Future<void> runBuild() async {
  String commandSeparator = Platform.isWindows ? '`' : '\\';
  String platforms = 'android';
  if (Platform.isLinux) platforms += ',linux';
  if (Platform.isWindows) platforms += ',windows';
  await runCommand(
    command: '''
cd example; $commandSeparator
flutter clean && flutter pub get; $commandSeparator
flutter pub run flutter_app_builder -v --platforms=$platforms''',
  );
}
