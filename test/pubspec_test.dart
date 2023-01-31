import 'dart:io';

import 'package:flutter_app_builder/pubspec.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  final pubspecFile = File('example/pubspec.yaml');
  late String pubspecString;
  late Pubspec pubspec;

  setUpAll(() async {
    pubspecString = await pubspecFile.readAsString();
  });

  setUp(() {
    pubspec = Pubspec(pubspecString: pubspecString);
  });

  group('Pubspec:', () {
    test('instantiates correctly from yaml string', () {
      expect(pubspec, isA<Pubspec>());
    });

    test('has a name', () {
      expect(pubspec.name, 'example');
    });

    test('has an app display name', () {
      expect(pubspec.appDisplayName, 'Incredible App');
    });

    test('has an author', () {
      expect(pubspec.author, 'Amazing Coder');
    });

    test('has an identifier', () {
      expect(pubspec.identifier, 'com.example.incredibleapp');
    });

    test('languages is populated', () {
      expect(pubspec.languages, ['en', 'de']);
    });

    test('has an msix identity name', () {
      expect(pubspec.msixIdentityName, 'com.example.incredibleapp');
    });

    test('has an msix publisher', () {
      expect(pubspec.msixPublisher, 'CN=0AA9AN0R-36HN-4N7F-JJF4-E300K747CB9D');
    });

    test('has an msix icon path', () {
      expect(
        pubspec.msixIconPath,
        r'assets\icons\com.example.incredibleapp.png',
      );
    });

    test('has an msix capabilities', () {
      expect(pubspec.msixCapabilities, 'internetClient');
    });

    test('has a version', () {
      expect(pubspec.version, Version(1, 0, 0, build: '+1'));
    });
  });
}
