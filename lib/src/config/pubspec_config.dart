import 'dart:convert';
import 'dart:io';
import 'package:yaml/yaml.dart' as yaml;

class PubspecConfig {
  final Uri url;
  final int projectId;
  final String outputDir;

  const PubspecConfig._({this.url, this.projectId, this.outputDir});

  /// Creates a [PubspecConfig] from the `pubspec.yaml` file in project directory.
  factory PubspecConfig.fromPubspec() {
    final pubspecBytes = File('pubspec.yaml').readAsBytesSync();
    final pubspec = yaml.loadYaml(utf8.decode(pubspecBytes))['arbify'] ?? {};

    return PubspecConfig._(
      url: Uri.tryParse(pubspec['url'] ?? ''),
      projectId: pubspec['project_id'],
      outputDir: pubspec['output_dir'],
    );
  }

  @override
  String toString() =>
      'PubspecConfig { url: $url, projectId: $projectId, outputDir: $outputDir }';
}
