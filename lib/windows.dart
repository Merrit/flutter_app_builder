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

  Future<void> package() async {
    _log.info('Packaging Windows build.');
    await _createInstaller();
    await _copyVCRuntime();
    await _compressPortable();
  }

  Future<void> _createInstaller() async {
    await Terminal.runCommand(
      command: 'flutter pub run msix:create '
          '--display-name="${_env.appDisplayName}" '
          '--publisher-display-name="${_env.author}" '
          '--identity-name="${_env.identifier}" '
          '--logo-path="${_env.msixIconPath}" '
          '--capabilities="" '
          '--trim-logo=false '
          '--output-path="${_buildDir.absolute.path}" '
          '--output-name="${_env.appDisplayName}-Windows-Installer" '
          '--build-windows=false',
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
    Terminal.runCommand(
      command:
          'compress-archive -Path ${_buildDir.absolute.path}\\* -DestinationPath "${_env.outputDir.absolute.path}\\$zipFileName"',
    );
    await portableFile.delete();
  }
}
