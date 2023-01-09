import 'dart:io';

import 'android.dart';
import 'environment.dart';
import 'linux.dart';
import 'logging_manager.dart';
import 'terminal.dart';
import 'windows.dart';

// TODO: De-duplicate a bunch of this stuff. Probably should be all in this
// Builder class.. Set variables like path once at the beginning that steps can
// refer to without having to constantly check the platform.

class Builder {
  Future<void> run() async {
    for (var target in Environment.instance.targets) {
      switch (target) {
        case Target.linux:
          await _buildPlatform('linux');
          await Linux().package();
          break;
        case Target.windows:
          final windows = Windows();
          await _buildPlatform('windows');
          await windows.package();
          break;
        case Target.android:
          await _buildPlatform('appbundle');
          await Android().moveAppBundle();
          await _buildPlatform('apk');
          await Android().moveApk();
          break;
      }
    }

    await _validateArchiveFilenames();
  }

  Future<String> _buildPlatform(String platform) async {
    log.v('Running build for $platform');

    return await Terminal.runCommand(
      command: 'flutter build -v $platform --release',
    );
  }

  Future<void> _validateArchiveFilenames() async {
    final separator = (Platform.isWindows) ? '\\' : '/';

    for (var file in Environment.instance.outputDir.listSync()) {
      final name = file.path.split(separator).last;
      final validatedName = name.replaceAll(' ', '');
      await file.rename(
        Environment.instance.outputDir.absolute.path +
            separator +
            validatedName,
      );
    }
  }
}
