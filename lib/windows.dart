import 'dart:io';

import 'package:logging/logging.dart';

import 'constants.dart';
import 'environment.dart';
import 'terminal.dart';

final _log = Logger('Windows');

class Windows {
  final String _buildPath = BuildPath.windows;
  final Directory _buildDir = Directory(BuildPath.windows);
  final Environment _env;
  final String zipFileName;

  Windows._({
    required this.zipFileName,
  }) : _env = Environment.instance;

  factory Windows() {
    final env = Environment.instance;

    return Windows._(
      zipFileName: '${env.appDisplayName}-Windows-Portable.zip',
    );
  }

  /// Updates the `Runner.rc` file for the Windows build so it has the correct
  /// version information. (windows/runner/Runner.rc)
  Future<void> updateVersion() async {
    _log.info('Updating Windows version string.');

    final version = Environment.instance.version;

    final runnerRcFile = File('windows\\runner\\Runner.rc');
    String runnerRc = await runnerRcFile.readAsString();
    runnerRc = runnerRc
        .replaceAll(
          RegExp(r'(?<=#define VERSION_AS_NUMBER )\d.*'),
          '${version.major},${version.minor},${version.patch}',
        )
        .replaceAll(
          RegExp(r'(?<=#define VERSION_AS_STRING ")\d.*(?=")'),
          '${version.major}.${version.minor}.${version.patch}',
        );

    await runnerRcFile.writeAsString(runnerRc);
  }

  Future<void> package() async {
    _log.info('Packaging Windows build.');
    await _addBuildInfo();
    await _createInstaller();
    await _copyVCRuntime();
    await _compressPortable();
  }

  /// Add info about when this build occurred, only for preleases.
  Future<void> _addBuildInfo() async {
    if (Platform.environment['prerelease'] != 'true') return;
    final buildFile = File('$_buildPath/BUILD');
    await buildFile.writeAsString(DateTime.now().toString());
  }

  Future<void> _createInstaller() async {
    _log.info('Creating Windows msix installer.');

    await Terminal.runCommand(
      command: 'flutter pub run msix:create -v '
          '--store '
          '--build-windows=false '
          '--install-certificate=false '
          '--capabilities="${_env.msixCapabilities}" '
          '--trim-logo=false '
          '--display-name="${_env.appDisplayName}" '
          '--publisher-display-name="${_env.author}" '
          '--publisher="${_env.msixPublisher}" '
          '--identity-name="${_env.msixIdentityName}" '
          '--logo-path="${_env.msixIconPath}" '
          '--output-path="${_env.outputDir.absolute.path}" '
          '--output-name="${_env.appDisplayName}-Windows-Installer"',
    );
  }

  /// Copy VC redistributables to build directory.
  Future<void> _copyVCRuntime() async {
    await Terminal.runCommand(
      command:
          r"Copy-Item (vswhere -latest -find 'VC\Redist\MSVC\*\x64\*\msvcp140.dll') " +
              _buildDir.path,
    );
    await Terminal.runCommand(
      command:
          r"Copy-Item (vswhere -latest -find 'VC\Redist\MSVC\*\x64\*\vcruntime140.dll') " +
              _buildDir.path,
    );
    await Terminal.runCommand(
      command:
          r"Copy-Item (vswhere -latest -find 'VC\Redist\MSVC\*\x64\*\vcruntime140_1.dll') " +
              _buildDir.path,
    );
  }

  Future<void> _compressPortable() async {
    final portableFile = File('$_buildPath\\PORTABLE')..createSync();
    await Terminal.runCommand(
      command:
          'compress-archive -Path ${_buildDir.absolute.path}\\* -DestinationPath "${_env.outputDir.absolute.path}\\$zipFileName"',
    );
    await portableFile.delete();
  }
}
