import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

class Pubspec {
  final String name;
  final String? appDisplayName;
  final String? author;
  final String? identifier;
  final String? msixIconPath;
  final Version version;

  const Pubspec._({
    required this.name,
    required this.appDisplayName,
    required this.author,
    required this.identifier,
    required this.msixIconPath,
    required this.version,
  });

  factory Pubspec({required String pubspecString}) {
    final YamlMap pubspec = loadYaml(pubspecString);
    final YamlMap builderYaml = pubspec['flutter_app_builder'];

    return Pubspec._(
      name: pubspec['name'],
      appDisplayName: builderYaml['app_display_name'],
      author: builderYaml['author'],
      identifier: builderYaml['identifier'],
      msixIconPath: builderYaml['msix_icon_path'],
      version: Version.parse(pubspec['version']),
    );
  }
}
