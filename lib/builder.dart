import 'dart:io';

import 'package:logging/logging.dart';

import 'android.dart';
import 'environment.dart';
import 'linux.dart';
import 'terminal.dart';
import 'windows.dart';

final _log = Logger('Builder');

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
          await windows.updateVersion();
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
    _log.info('Running build for $platform');

    return await Terminal.runCommand(
      command: 'flutter build -v $platform --release',
    );
  }

  Future<void> _validateArchiveFilenames() async {
    final separator = (Platform.isWindows) ? '\\' : '/';

    for (var file in Environment.instance.outputDir.listSync()) {
      final name = file.path.split(separator).last;
      final validatedName = name.replaceAll(' ', '');
      await file.rename(validatedName);
    }
  }
}
