import 'dart:io';

import 'constants.dart';
import 'environment.dart';
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

  Future<void> package() async {
    await _createInstaller();
    _moveInstallerToOutput();
    await _copyVCRuntime();
    await _compressPortable();
  }

  Future<void> _createInstaller() async {
    await Terminal.runCommand(
      command:
          'flutter pub run msix:create --display-name="${_env.appDisplayName}" --publisher-display-name="${_env.author}" --identity-name="${_env.identifier}" --logo-path="${_env.msixIconPath}" --capabilities="" --trim-logo=false',
    );
  }

  Future<void> _moveInstallerToOutput() async {
    await Terminal.runCommand(
      command:
          'mv ${_buildDir.absolute.path}\\*.msix "${_env.outputDir.absolute.path}\\${_env.appDisplayName}-Windows-Installer.msix"',
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
