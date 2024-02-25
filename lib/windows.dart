import 'dart:io';

import 'constants.dart';
import 'environment.dart';
import 'logging_manager.dart';
import 'pubspec.dart';
import 'terminal.dart';

class Windows {
  final String _buildPath;
  final Directory _buildDir;
  final Environment _env;
  final String zipFileName;

  Windows._(
    this._buildPath,
    this._buildDir, {
    required this.zipFileName,
  }) : _env = Environment.instance;

  factory Windows({required BuildPath buildPath}) {
    final env = Environment.instance;

    return Windows._(
      buildPath.windows,
      Directory(buildPath.windows),
      zipFileName: '${env.appDisplayName}-Windows-Portable.zip',
    );
  }

  Future<void> package() async {
    log.i('Packaging Windows build.');
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
    log.i('Creating Windows installer.');

    final version = _env.version;
    final versionString = '${version.major}.${version.minor}.${version.patch}';

    await Terminal.runCommand(
      command:
          'iscc packaging\\windows\\inno_setup.iss /DAppVersion=$versionString',
    );
  }

  Future<void> _createMsixInstaller() async {
    log.i('Creating Windows msix installer.');

    // Using -v with this command causes `FINE` logs to output to stderr, which
    // causes the build to fail. So we're not using it.
    String command = 'flutter pub run msix:create '
        '--build-windows=false '
        '--capabilities="${_env.msixCapabilities}" '
        '--trim-logo=false '
        '--display-name="${_env.appDisplayName}" '
        '--logo-path="${_env.msixIconPath}" '
        '--output-path="${_env.outputDir.absolute.path}" '
        '--output-name="${_env.appDisplayName}-Windows-Store-Installer" ';

    if (Pubspec.instance.languages != null) {
      command += '--languages="${Pubspec.instance.languages!.join(',')}" ';
    }

    if (_env.msixPublisher != null) {
      // Building for Microsoft Store.
      log.i('Building with config for Microsoft Store.');
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
