import 'android.dart';
import 'environment.dart';
import 'linux.dart';
import 'terminal.dart';
import 'windows.dart';

class Builder {
  Future<void> run() async {
    for (var target in Environment.instance.targets) {
      switch (target) {
        case Target.linux:
          await _buildPlatform('linux');
          await Linux().package();
          break;
        case Target.windows:
          await _buildPlatform('windows');
          await Windows().package();
          break;
        case Target.android:
          await _buildPlatform('appbundle');
          await Android().moveAppBundle();
          await _buildPlatform('apk');
          await Android().moveApk();
          break;
      }
    }
  }

  Future<String> _buildPlatform(String platform) async {
    return await Terminal.runCommand(
      command: 'flutter build -v $platform --release',
    );
  }
}
