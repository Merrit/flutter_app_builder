import 'dart:io';

import 'constants.dart';
import 'environment.dart';
import 'logging_manager.dart';
import 'terminal.dart';

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
    log.v('Updating Windows version string.');

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
    log.v('Packaging Windows build.');
    await _addReadme();
    await _createInstaller();
    await _createMsixInstaller();
    await _copyVCRuntime();
    await _compressPortable();
  }

  Future<void> _addReadme() async {
    final readme = File('README.md');
    final exists = await readme.exists();
    if (!exists) return;

    await readme.copy('$_buildPath\\README.md');
  }

  Future<void> _createInstaller() async {
    log.v('Creating Windows installer.');

    await Terminal.runCommand(
      command: r'iscc packaging\windows\inno_setup.iss',
    );
  }

  Future<void> _createMsixInstaller() async {
    log.v('Creating Windows msix installer.');

    String command = 'flutter pub run msix:create -v '
        '--build-windows=false '
        '--capabilities="${_env.msixCapabilities}" '
        '--trim-logo=false '
        '--display-name="${_env.appDisplayName}" '
        '--logo-path="${_env.msixIconPath}" '
        '--output-path="${_env.outputDir.absolute.path}" '
        '--output-name="${_env.appDisplayName}-Windows-Store-Installer" ';

    if (_env.msixPublisher != null) {
      // Building for Microsoft Store.
      log.v('Building with config for Microsoft Store.');
      command += '--store ';
      command += '--publisher="${_env.msixPublisher}" ';
      command += '--publisher-display-name="${_env.author}" ';
      command += '--identity-name="${_env.msixIdentityName}" ';
      command += '--install-certificate=false ';
    }

    command = command.trimRight();

    await Terminal.runCommand(
      command: command,
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
    await _addBuildInfo();
    await Terminal.runCommand(
      command:
          'compress-archive -Path ${_buildDir.absolute.path}\\* -DestinationPath "${_env.outputDir.absolute.path}\\$zipFileName"',
    );
    await portableFile.delete();
  }

  /// Add info about when this build occurred, only for preleases.
  Future<void> _addBuildInfo() async {
    if (Platform.environment['GITHUB_WORKFLOW'] != 'Pre-Release') return;

    final buildFile = File('$_buildPath\\BUILD');
    await buildFile.writeAsString(DateTime.now().toUtc().toString());
  }
}
