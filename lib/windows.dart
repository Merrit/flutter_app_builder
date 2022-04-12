import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

import 'constants.dart';
import 'environment.dart';
import 'terminal.dart';

class Windows {
  final String _buildPath = BuildPath.windows;
  final Directory _buildDir = Directory(BuildPath.windows);
  final Environment _env = Environment.instance;

  Future<void> package() async {
    await _copyVCRuntime();
    await _compressPortable();
    await _createInstaller();
    _moveInstallerToOutput();
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
    final zipFileName = '${_env.appDisplayName}-Windows-Portable.zip';
    Terminal.runCommand(
      command:
          'compress-archive -Path ${_buildDir.absolute.path}\\* -DestinationPath ${_env.outputDir.absolute.path}\\$zipFileName',
    );
    await portableFile.delete();
  }

  Future<void> _createInstaller() async {
    await Terminal.runCommand(
      command:
          'flutter pub run msix:create --display-name="${_env.appDisplayName}" --publisher-display-name="${_env.author}" --identity-name="${_env.identifier}" --logo-path="${_env.msixIconPath}" --capabilities="" --trim-logo=false --store=false',
    );
  }

  void _moveInstallerToOutput() {
    final glob = Glob('*.msix');
    for (var entity in glob.listSync()) {
      entity.renameSync(
        _env.outputDir.path + '${_env.appDisplayName}-Windows-Installer.msix',
      );
    }
  }
}
