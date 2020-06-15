import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

class OutputFileUtils {
  final String outputDir;

  const OutputFileUtils({@required this.outputDir});

  bool dirExists() => _dir().existsSync();

  void createDir() => _dir().createSync(recursive: true);

  List<String> fetch([Pattern pattern]) {
    var files = _dir().listSync().whereType<File>();

    if (pattern != null) {
      files = files.where(
          (file) => pattern.allMatches(path.basename(file.path)).isNotEmpty);
    }

    return files.map((file) => file.readAsStringSync()).toList();
  }

  void put(String filename, String contents) {
    File(path.join(outputDir, filename)).writeAsStringSync(contents);
  }

  Directory _dir() => Directory(outputDir);
}
