import 'dart:io';

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

  GitHub._({
    required this.eventName,
    required this.refName,
    // this.releaseToken,
  });

  static late final GitHub instance;

  factory GitHub.initialize() {
    final env = Platform.environment;

    instance = GitHub._(
      eventName: env['GITHUB_EVENT_NAME']!,
      refName: env['GITHUB_REF_NAME']!,
      // releaseToken: env['GITHUB_TOKEN'],
    );

    return instance;
  }

  Future<void> uploadArtifactsToDraftRelease() async {
    // This is currently being handled by the GitHub Workflow.
    return;

    // Script should only run on push events if they were for a new tag.
    // Therefore, if the event is not a push we aren't making a release.
    // if (eventName != 'push') return;

    // log.i('Uploading artifacts to a draft release');

    // String command;

    // if (_env.targetingWindows) {
    //   // (get-item) is needed because `gh` does not auto-expand wildcards.
    //   command =
    //       'gh release upload $refName (get-item ${_env.outputDir.absolute.path}\\*) --clobber';
    // } else {
    //   command = 'gh release upload $refName output/* --clobber';
    // }

    // await Terminal.runCommand(command: command);
  }
}
