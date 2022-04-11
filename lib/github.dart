import 'dart:io';

import 'environment.dart';
import 'terminal.dart';

class GitHub {
  /// The name of the event that triggered the workflow.
  ///
  /// For example, `workflow_dispatch`.
  final String eventName;

  /// The branch or *tag* name that triggered the workflow run.
  ///
  /// For example, `v2.3.2`.
  final String refName;

  ///// The secret token required to upload to / create a release.
  // final String? releaseToken;

  const GitHub({
    required this.eventName,
    required this.refName,
    // this.releaseToken,
  });

  factory GitHub.initialize() {
    final env = Platform.environment;

    return GitHub(
      eventName: env['GITHUB_EVENT_NAME']!,
      refName: env['GITHUB_REF_NAME']!,
      // releaseToken: env['GITHUB_TOKEN'],
    );
  }

  Future<void> uploadArtifactsToDraftRelease() async {
    // Script should only run on push events if they were for a new tag.
    // Therefore, if the event is not a push we aren't making a release.
    if (eventName != 'push') return;

    String command;

    if (Environment.instance.targetingWindows) {
      // (get-item) is needed because `gh` does not auto-expand wildcards.
      command = 'gh release upload $refName (get-item .\\output\\*) --clobber';
    } else {
      command = 'gh release upload $refName output/* --clobber';
    }

    await Terminal.runCommand(command: command);
  }
}
